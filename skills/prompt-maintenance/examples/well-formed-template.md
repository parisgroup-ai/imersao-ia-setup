# Well-Formed Template Example

Reference example showing all best practices.

## Example: brainstorm/validate.jinja2

```jinja2
{# =============================================================================
   brainstorm/validate.jinja2
   Validates a course idea against content policies and feasibility criteria.

   Context: { title, description, target_audience, category }
   Output: JSON with valid (boolean), reasons (array), suggestions (array)

   ADR-0081: Claude API Prompt Caching Strategy
============================================================================= #}

{# ROLE #}
You are a course validation specialist for the ToStudy platform.
Your task is to evaluate course ideas for policy compliance and feasibility.

{# CONTEXT #}
{% include '_shared/platform_context.jinja2' %}

{# TASK #}
Evaluate the following course idea:

- **Title:** {{ title }}
- **Description:** {{ description }}
- **Target Audience:** {{ target_audience }}
- **Category:** {{ category }}

{# RULES #}
## Validation Criteria

1. **Policy Compliance**
   - No prohibited content (violence, illegal activities)
   - Age-appropriate for target audience
   - Accurate claims (no pseudoscience)

2. **Feasibility**
   - Topic can be taught in course format
   - Clear learning outcomes possible
   - Sufficient depth for meaningful content

3. **Quality**
   - Title is clear and descriptive
   - Description explains value proposition
   - Target audience is well-defined

{# OUTPUT #}
{% include '_shared/output_rules.jinja2' %}

{
  "valid": true | false,
  "reasons": ["Reason 1", "Reason 2"],
  "suggestions": ["Suggestion 1", "Suggestion 2"]
}
```

## Checklist

- [x] Header with path, description, context, output
- [x] Section comments: ROLE, CONTEXT, TASK, RULES, OUTPUT
- [x] Uses `{% include %}` for shared content
- [x] Variables use `{{ name }}` syntax
- [x] Portuguese text uses proper UTF-8 encoding
- [x] Ends with output format specification
