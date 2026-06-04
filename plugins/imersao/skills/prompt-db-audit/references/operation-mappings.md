# Operation Type Mappings

Mapeamento entre `operationType` (usado em `set_llm_operation_type()`) e templates de prompt.

## Convenção de Nomenclatura

O mapeamento segue a convenção:

```
operationType: '{domain}_{action}'
template:      '{domain}/{action}.jinja2' OR '{domain}/system.jinja2'
```

**Exemplos:**
- `spark_interview` → `interview/system.jinja2`
- `study_tutor` → `study/tutor_system.jinja2`
- `outline_generation` → `outline/generate.jinja2`

## Mapeamentos Conhecidos

### Spark & Interview

| operationType | Template | Arquivo Python |
|---------------|----------|----------------|
| `spark_interview` | `interview/system.jinja2` | `services/interview_service.py` |
| `spark_chat` | `spark/system.jinja2` | `services/spark/message_processor.py` |
| `intent_classification` | `spark/intent_classification.jinja2` | `services/intent_classifier.py` |
| `topic_extraction` | `spark/topic_extraction.jinja2` | `services/topic_extractor.py` |

### Study & Tutor

| operationType | Template | Arquivo Python |
|---------------|----------|----------------|
| `study_tutor` | `study/tutor_system.jinja2` | `routers/study_chat.py` |
| `study_code_validation` | `study/code_validation.jinja2` | `routers/study_chat.py` |
| `study_hint_generation` | `study/hint_generation.jinja2` | `routers/study_chat.py` |
| `study_course_session` | `study/course_tutor.jinja2` | `routers/study_course.py` |
| `study_course_message_stream` | `study/course_tutor.jinja2` | `routers/study_course.py` |
| `study_course_navigation` | `study/course_tutor.jinja2` | `routers/study_course.py` |
| `study_course_validation` | `study/code_validation.jinja2` | `routers/study_course.py` |
| `study_course_hint` | `study/hint_generation.jinja2` | `routers/study_course.py` |
| `study_compaction` | *(sem template dedicado)* | `services/study/compaction_engine.py` |
| `context_summarization` | `tutor/summarization_system.jinja2` | `jobs/context_summarizer.py` |
| `tutor_question` | `tutor/system.jinja2` | `routers/tutor_context.py` |

### Course Generation

| operationType | Template | Arquivo Python |
|---------------|----------|----------------|
| `outline_generation` | `outline/generate.jinja2` | `services/outline_generator.py` |
| `module_regeneration` | `module/generate.jinja2` | `services/spark_course_generator.py` |
| `exercise_lesson_generation` | `lesson/exercise.jinja2` | `services/module_generator.py` |
| `single_lesson_generation` | `lesson/*.jinja2` | `services/module_generator.py` |
| `lesson_structure_generation` | `lesson/structure.jinja2` | `services/incremental_module_generator.py` |

### Extraction & Processing

| operationType | Template | Arquivo Python |
|---------------|----------|----------------|
| `idea_extraction` | `extraction/extraction_system.jinja2` | `services/idea_extractor.py` |
| `idea_enrichment` | `extraction/enrichment_system.jinja2` | `services/idea_extractor.py` |
| `project_extraction` | `extraction/project_system.jinja2` | `services/project_extractor.py` |
| `course_metadata_extraction` | `extraction/course_metadata_system.jinja2` | `services/course_metadata_extractor.py` |

### Knowledge Processing

| operationType | Template | Arquivo Python |
|---------------|----------|----------------|
| `knowledge_processing` | *(dinâmico)* | `routers/knowledge.py` |
| `knowledge_batch_processing` | *(dinâmico)* | `routers/knowledge.py` |
| `relationship_analysis` | *(dinâmico)* | `routers/knowledge.py` |
| `relationship_detection` | *(dinâmico)* | `services/relationship_detector.py` |
| `query_topic_extraction` | `spark/topic_extraction.jinja2` | `services/knowledge_processor.py` |
| `chunk_indexing` | *(sem template)* | `services/knowledge_processor.py` |

### Matrix & Translation

| operationType | Template | Arquivo Python |
|---------------|----------|----------------|
| `matrix_module_generation` | `module/matrix_framework.jinja2` + `module/matrix_user.jinja2` | `routers/matrix.py` |
| `matrix_translation` | `translation/_framework.jinja2` + `translation/request.jinja2` | `routers/matrix.py` |

### Video Prompts

| operationType | Template | Arquivo Python |
|---------------|----------|----------------|
| `video_prompt_generation` | `video_prompt/_framework.jinja2` + `video_prompt/*.jinja2` | `services/video_prompt_generator.py` |

## Operações Sem Template Dedicado

Estas operações usam prompts inline ou dinâmicos:

| operationType | Motivo |
|---------------|--------|
| `study_compaction` | Usa prompt construído dinamicamente |
| `chunk_indexing` | Usa embeddings, não LLM completion |
| `knowledge_processing` | Varia conforme tipo de conhecimento |

## Adicionando Novos Mapeamentos

No arquivo `.prompt-db-audit.json` do projeto:

```json
{
  "operationMappings": {
    "new_operation": "domain/template.jinja2",
    "another_operation": ["domain/system.jinja2", "domain/user.jinja2"]
  }
}
```

Mapeamentos podem ser:
- **String**: Um único template
- **Array**: Múltiplos templates (framework + user prompt)
