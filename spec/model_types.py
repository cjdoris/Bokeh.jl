# modified from https://github.com/bokeh/bokeh/blob/2.4.2/scripts/spec.py

import bokeh
assert bokeh.__version__ == '2.4.2'

import json

from bokeh.core.property.bases import UndefinedType
from bokeh.core.property.descriptors import AliasPropertyDescriptor
from bokeh.model import Model

import bokeh.models
import bokeh.models.widgets

def _proto(obj, defaults=False):
    return json.dumps(obj.to_json(defaults), sort_keys=True, indent=None)

data = []
for name, m in sorted(Model.model_class_reverse_map.items()):
    item = {
        'name'  : name,
        'fullname': m.__module__ + '.' + m.__name__,
        'bases' : [base.__module__ + '.' + base.__name__ for base in m.__bases__],
        'desc'  : m.__doc__,
    }
    props = []
    for prop_name in m.properties():
        descriptor = m.lookup(prop_name)
        if isinstance(descriptor, AliasPropertyDescriptor):
            continue

        prop = descriptor.property

        detail = {
            'name'    : prop_name,
            'type'    : str(prop),
            'desc'    : prop.__doc__,
        }

        default = descriptor.instance_default(m())

        if isinstance(default, UndefinedType):
            default = "<Undefined>"

        if isinstance(default, Model):
            default = _proto(default)

        if isinstance(default, (list, tuple)) and any(isinstance(x, Model) for x in default):
            default = [_proto(x) for x in default]

        if isinstance(default, dict) and any(isinstance(x, Model) for x in default.values()):
            default = { k: _proto(v) for k, v in default.items() }

        detail['default'] = default

        props.append(detail)

    item['props'] = props

    data.append(item)

with open('spec/model_types.json', 'wt') as fp:
    json.dump(data, fp, indent=2)
