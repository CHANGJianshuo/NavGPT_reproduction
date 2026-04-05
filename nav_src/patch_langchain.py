"""Patch LangChain 0.0.246 ChatOpenAI to handle string responses from proxies."""
import json
from typing import Any, Mapping
from langchain.chat_models.openai import ChatOpenAI
from langchain.schema import ChatResult, ChatGeneration
from langchain.chat_models.openai import _convert_dict_to_message

_original_create_chat_result = ChatOpenAI._create_chat_result

def _patched_create_chat_result(self, response: Any) -> ChatResult:
    # Some proxies return a string instead of a dict; parse it
    if isinstance(response, str):
        response = json.loads(response)
    return _original_create_chat_result(self, response)

ChatOpenAI._create_chat_result = _patched_create_chat_result
