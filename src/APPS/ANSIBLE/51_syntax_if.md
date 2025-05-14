# if

```yaml
# just a quick one, short if with variables

{% if variable_that_is_a_STRING %}
... # so in this case if a variable is empty string ("") the if doesn't pass
... # if one or more characters, if passes
{% endif %}

{% if variable_that_is_a_LIST %}
... # so in this case if a variable is empty list ([]) the if doesn't pass
... # if one or more element, if passes
{% endif %}
```
