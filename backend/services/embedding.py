"""
Embedding Service - 生成文本嵌入向量
使用本地开源中文模型
"""
import logging
from typing import List
import numpy as np

logger = logging.getLogger(__name__)

class EmbeddingService:
    """文本嵌入服务基类"""

    async def encode(self, text: str) -> List[float]:
        """生成文本的embedding向量"""
        raise NotImplementedError

    async def encode_batch(self, texts: List[str]) -> List[List[float]]:
        """批量生成embedding向量"""
        raise NotImplementedError

    def cosine_similarity(self, vec1: List[float], vec2: List[float]) -> float:
        """计算余弦相似度"""
        try:
            a = np.array(vec1)
            b = np.array(vec2)
            return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))
        except:
            return 0.0


class MockEmbeddingService(EmbeddingService):
    """
    Mock Embedding服务
    基于TF-IDF的简单实现（用于开发测试）
    """

    def __init__(self):
        from sklearn.feature_extraction.text import TfidfVectorizer
        import jieba

        self.vectorizer = TfidfVectorizer(
            tokenizer=lambda x: list(jieba.cut(x)),
            max_features=384,  # 与常见embedding维度一致
            token_pattern=None
        )
        self.fitted = False
        logger.warning("使用Mock Embedding服务 (TF-IDF)")

    async def encode(self, text: str) -> List[float]:
        """生成文本的TF-IDF向量"""
        if not self.fitted:
            # 首次调用时拟合
            self.vectorizer.fit([text])
            self.fitted = True

        vector = self.vectorizer.transform([text])
        return vector.toarray()[0].tolist()

    async def encode_batch(self, texts: List[str]) -> List[List[float]]:
        """批量生成向量"""
        if not self.fitted:
            self.vectorizer.fit(texts)
            self.fitted = True

        vectors = self.vectorizer.transform(texts)
        return vectors.toarray().tolist()


class SentenceTransformerEmbedding(EmbeddingService):
    """
    基于Sentence Transformers的Embedding服务
    使用开源中文模型
    """

    def __init__(self, model_name: str = "paraphrase-multilingual-MiniLM-L12-v2"):
        """
        初始化模型
        推荐的中文模型：
        - paraphrase-multilingual-MiniLM-L12-v2 (多语言，包括中文)
        - shibing624/text2vec-base-chinese (专门的中文模型，需要安装)
        """
        try:
            from sentence_transformers import SentenceTransformer
            self.model = SentenceTransformer(model_name)
            self.dimension = self.model.get_sentence_embedding_dimension()
            logger.info(f"加载Sentence Transformer模型: {model_name} (维度: {self.dimension})")
        except ImportError:
            logger.warning("sentence-transformers未安装，使用Mock服务")
            return MockEmbeddingService()
        except Exception as e:
            logger.error(f"加载模型失败: {e}，使用Mock服务")
            return MockEmbeddingService()

    async def encode(self, text: str) -> List[float]:
        """生成文本的embedding向量"""
        try:
            embedding = self.model.encode(text, convert_to_numpy=True)
            return embedding.tolist()
        except Exception as e:
            logger.error(f"生成embedding失败: {e}")
            return [0.0] * 384  # 返回零向量

    async def encode_batch(self, texts: List[str]) -> List[List[float]]:
        """批量生成embedding向量"""
        try:
            embeddings = self.model.encode(texts, convert_to_numpy=True)
            return embeddings.tolist()
        except Exception as e:
            logger.error(f"批量生成embedding失败: {e}")
            return [[0.0] * 384] * len(texts)


# 全局服务实例
_embedding_service = None

def get_embedding_service() -> EmbeddingService:
    """获取embedding服务实例"""
    global _embedding_service
    if _embedding_service is None:
        # 优先使用Sentence Transformer，失败则使用Mock
        try:
            from sentence_transformers import SentenceTransformer
            _embedding_service = SentenceTransformerEmbedding()
            if isinstance(_embedding_service, MockEmbeddingService):
                # 如果初始化失败回退到Mock
                _embedding_service = MockEmbeddingService()
        except:
            _embedding_service = MockEmbeddingService()

    return _embedding_service


def compute_similarity(query_embedding: List[float],
                      doc_embedding: List[float]) -> float:
    """
    计算两个embedding向量的余弦相似度
    返回值范围：[-1, 1]，1表示完全相似，0表示不相关，-1表示完全相反
    """
    try:
        a = np.array(query_embedding)
        b = np.array(doc_embedding)

        # 防止除零
        norm_a = np.linalg.norm(a)
        norm_b = np.linalg.norm(b)

        if norm_a == 0 or norm_b == 0:
            return 0.0

        return float(np.dot(a, b) / (norm_a * norm_b))
    except Exception as e:
        logger.error(f"计算相似度失败: {e}")
        return 0.0
