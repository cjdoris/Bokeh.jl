# This script extracts various bits of information from the Python library to re-use in the
# Julia package:
# - Models (names, bases, props, docstrings)
# - Named colors
# - Palettes
# - Hatch patterns
# - Dash patterns


# modified from https://github.com/bokeh/bokeh/blob/2.4.2/scripts/spec.py

import bokeh
assert bokeh.__version__ == '3.0.3'

import json
import inspect

import docutils.parsers.rst
import docutils.utils

from bokeh.core.property.bases import UndefinedType
from bokeh.core.property.descriptors import AliasPropertyDescriptor
from bokeh.core.property_mixins import HasProps
from bokeh.core.serialization import Serializer
from bokeh.model import Model

import bokeh.plotting  # so that Figure is included when enumerating model types
import bokeh.palettes
import bokeh.colors.named
import bokeh.models
import bokeh.models.widgets
import bokeh.core.enums
import bokeh.core.property.visual
import bokeh.themes

def save(data, name):
    with open(f'spec/{name}.json', 'wt') as fp:
        json.dump(data, fp)

def mkdesc(doc):
    doc = inspect.cleandoc(doc)
    # doc = pandoc.read(doc, format="rst")
    # doc = pandoc.write(doc, format="markdown")
    return doc

RST_SETTINGS = docutils.frontend.OptionParser(components=(docutils.parsers.rst.Parser,)).get_default_values()
RST_PARSER = docutils.parsers.rst.Parser()

def mkrichdesc(text, name):
    text = inspect.cleandoc(text)
    doc = docutils.utils.new_document(name, RST_SETTINGS)
    try:
        RST_PARSER.parse(text, doc)
    except Exception:
        return
    return _walkdoc(doc)

def _walkdoc(doc):
    if isinstance(doc, str):
        return str(doc)
    else:
        return {
            'type': doc.tagname,
            'children': [_walkdoc(x) for x in doc.children]
        }


### MODELS

def _name(model):
    return 'Model' if model is Model else model.__qualified_model__

def _proto(obj):
    t = type(obj)
    x = obj.to_serializable(Serializer())
    del x['id']  # id is not informative, by excluding it we can find more inherited props
    x['__type__'] = _name(t)
    return json.dumps(x, sort_keys=True, indent=None)

data = []
for name, m in sorted(Model.model_class_reverse_map.items()):
    assert _name(m) == name
    print('Model:', name)
    item = {
        'name'  : _name(m),
        'bases' : [_name(t) for t in m.__bases__ if issubclass(t, Model)],
        'mro': [_name(t) for t in m.__mro__ if issubclass(t, Model)],
        'desc'  : mkdesc(m.__doc__ or ""),
        'richdesc': mkrichdesc(m.__doc__ or "", name),
    }
    view_model = getattr(m, '__view_model__', None)
    if view_model is not None:
        if '.' in item['name']:
            view_type = m.__view_module__ + '.' + view_model
        else:
            view_type = view_model
        if view_type != item['name']:
            item['view_type'] = view_type
    view_subtype = getattr(m, '__subtype__', None)
    if view_subtype is not None:
        item['view_subtype'] = view_subtype
    props = []
    props_names = set()
    def find_props(m):
        for prop_name in m.__properties__: # __properties__ does not include inherited props
            if prop_name in props_names:
                continue
            print('Property:', prop_name)
            descriptor = m.lookup(prop_name)
            if isinstance(descriptor, AliasPropertyDescriptor):
                continue

            prop = descriptor.property

            detail = {
                'name'    : prop_name,
                'type'    : str(prop),
                'desc'    : mkdesc(prop.__doc__ or ""),
                'richdesc': mkrichdesc(prop.__doc__ or '', '{name}.{prop_name}'),
            }

            default = descriptor.instance_default(m())

            if isinstance(default, UndefinedType):
                default = "<Undefined>"

            if isinstance(default, Model):
                default = _proto(default)

            if isinstance(default, (list, tuple, set)) and any(isinstance(x, Model) for x in default):
                default = [_proto(x) for x in default]

            if isinstance(default, dict) and any(isinstance(x, Model) for x in default.values()):
                default = { k: _proto(v) for k, v in default.items() }

            if isinstance(default, (bokeh.core.property.vectorization.Field, bokeh.core.property.vectorization.Value)):
                default = default.to_serializable(Serializer())

            if isinstance(default, (list, tuple, set)):
                default = list(default)

            assert default is None or isinstance(default, (str, bool, float, list, int, dict))

            detail['default'] = default

            props.append(detail)
            props_names.add(prop_name)

            # include properties from any bases which are not models, since these are not enumerated
            for b in m.__bases__:
                if issubclass(b, HasProps) and not issubclass(b, Model):
                    find_props(b)
    find_props(m)
    props.sort(key=lambda x: x['name'])

    item['props'] = props

    data.append(item)

save(data, 'model_types')


### PALETTES

palette_set = {p for ps in bokeh.palettes.all_palettes.values() for p in ps.values()}
assert all(isinstance(p, tuple) for p in palette_set)
palettes = {k:v for (k,v) in bokeh.palettes.__dict__.items() if isinstance(v, tuple) and v in palette_set}
save({'all':palettes, 'grouped':bokeh.palettes.all_palettes}, 'palettes')


### NAMED COLORS

colors = {c.name:c.to_hex() for c in bokeh.colors.named.colors}
save(colors, 'colors')


### HATCH PATTERNS

hatch_patterns = dict(bokeh.core.enums._hatch_patterns)
save(hatch_patterns, 'hatch_patterns')


### DASH PATTERNS

dash_patterns = bokeh.core.property.visual.DashPattern._dash_patterns
save(dash_patterns, 'dash_patterns')


### THEMES

themes = {k: v._json for (k, v) in bokeh.themes.built_in_themes.items()}
save(themes, 'themes')
