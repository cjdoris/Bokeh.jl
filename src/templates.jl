indent(x, n) = join(readlines(IOBuffer(x)), "\n" * " "^n)
tojson(x) = JSON3.write(x)

function template_try_run_js(; code)
    """
    (function(root) {
        function embed_document(root) {
            $(indent(code, 8))
        }
        if (root.Bokeh !== undefined) {
          embed_document(root);
        } else {
          let attempts = 0;
          const timer = setInterval(function(root) {
            if (root.Bokeh !== undefined) {
              clearInterval(timer);
              embed_document(root);
            } else {
              attempts++;
              if (attempts > 100) {
                clearInterval(timer);
                console.log("Bokeh: ERROR: Unable to run BokehJS code because BokehJS library is missing");
              }
            }
          }, 10, root)
        }
      })(window);
      """
end

function template_doc_js(; docs_json, render_items, app_path=nothing, absolute_url=nothing)
    code = """
    const docs_json = $docs_json;
    const render_items = $render_items;
    root.Bokeh.embed.embed_items(docs_json, render_items$(app_path===nothing ? "" : ", $(tojson(app_path))")$(absolute_url===nothing ? "" : ", $(tojson(absolute_url))"));
    """
    template_try_run_js(code=code)
end

function template_autoload_js(; code, force=false, register_mimetype=nothing, autoload_init=nothing, elementid=nothing, run_inline_js=nothing, bundle=nothing, js_urls=[], css_urls=[], js_raw=[], css_raw=[])
    if autoload_init === nothing && elementid !== nothing
        autoload_init = """
        const element = document.getElementById($(tojson(elementid)));
        if (element == null) {
            console.warn("Bokeh: autoload.js configured with elementid '$elementid' but no matching script tag was found.")
        }
        """
    end
    inline_js_funcs = []
    for css in (bundle===nothing ? css_raw : bundle.css_raw)
        push!(inline_js_funcs, """
        function(Bokeh) {
            inject_raw_css($(tojson(css)));
        },
        """)
    end
    for js in (bundle===nothing ? js_raw : bundle.js_raw)
        push!(inline_js_funcs, """
        function(Bokeh) {
            $(indent(js, 4))
        },
        """)
    end
    push!(inline_js_funcs, """
    function(Bokeh) {
        $(indent(code, 4))
    }
    """)
    if run_inline_js === nothing
        run_inline_js = """
        for (let i = 0; i < inline_js.length; i++) {
            inline_js[i].call(root, root.Bokeh);
        }
        """
    end
    """
    (function(root) {
        function now() {
            return new Date();
        }

        const force = $(tojson(force));

        if (typeof root._bokeh_onload_callbacks === "undefined" || force === true) {
            root._bokeh_onload_callbacks = [];
            root._bokeh_is_loading = undefined;
        }

        $(register_mimetype===nothing ? "" : indent(register_mimetype, 4))

        $(autoload_init===nothing ? "" : indent(autoload_init, 4))

        function run_callbacks() {
            try {
            root._bokeh_onload_callbacks.forEach(function(callback) {
                if (callback != null)
                callback();
            });
            } finally {
            delete root._bokeh_onload_callbacks
            }
            console.debug("Bokeh: all callbacks have finished");
        }

        function load_libs(css_urls, js_urls, callback) {
            if (css_urls == null) css_urls = [];
            if (js_urls == null) js_urls = [];

            root._bokeh_onload_callbacks.push(callback);
            if (root._bokeh_is_loading > 0) {
                console.debug("Bokeh: BokehJS is being loaded, scheduling callback at", now());
                return null;
            }
            if (js_urls == null || js_urls.length === 0) {
                run_callbacks();
                return null;
            }
            console.debug("Bokeh: BokehJS not loaded, scheduling load and callback at", now());
            root._bokeh_is_loading = css_urls.length + js_urls.length;

            function on_load() {
                root._bokeh_is_loading--;
                if (root._bokeh_is_loading === 0) {
                    console.debug("Bokeh: all BokehJS libraries/stylesheets loaded");
                    run_callbacks()
                }
            }

            function on_error(url) {
                console.error("failed to load " + url);
            }

            for (let i = 0; i < css_urls.length; i++) {
                const url = css_urls[i];
                const element = document.createElement("link");
                element.onload = on_load;
                element.onerror = on_error.bind(null, url);
                element.rel = "stylesheet";
                element.type = "text/css";
                element.href = url;
                console.debug("Bokeh: injecting link tag for BokehJS stylesheet: ", url);
                document.body.appendChild(element);
            }

            for (let i = 0; i < js_urls.length; i++) {
                const url = js_urls[i];
                const element = document.createElement('script');
                element.onload = on_load;
                element.onerror = on_error.bind(null, url);
                element.async = false;
                element.src = url;
                console.debug("Bokeh: injecting script tag for BokehJS library: ", url);
                document.head.appendChild(element);
            }
        };

        function inject_raw_css(css) {
            const element = document.createElement("style");
            element.appendChild(document.createTextNode(css));
            document.body.appendChild(element);
        }

        const js_urls = $(tojson(bundle===nothing ? js_urls : bundle.js_urls));
        const css_urls = $(tojson(bundle===nothing ? css_urls : bundle.css_urls));

        const inline_js = [
            $(indent(join(inline_js_funcs, "\n"), 8))
        ];

        function run_inline_js() {
            $(run_inline_js === nothing ? "" : indent(run_inline_js, 8))
        }

        if (root._bokeh_is_loading === 0) {
            console.debug("Bokeh: BokehJS loaded, going straight to plotting");
            run_inline_js();
        } else {
            load_libs(css_urls, js_urls, function() {
            console.debug("Bokeh: BokehJS plotting callback run at", now());
            run_inline_js();
            });
        }
    }(window));
    """
end

function template_autoload_tag_html(; src_path, elementid)
    """
    <script src="$src_path" id="$elementid"></script>
    """
end

function template_autoload_tag_inline_html(; code, elementid)
    """
    <script id="$elementid">
        $(indent(code, 4))
    </script>
    """
end

function template_onload_js(; code)
    """
    (function() {
        const fn = function() {
            Bokeh.safely(function() {
                $(indent(code, 12))
            });
        };
        if (document.readyState != "loading") fn();
        else document.addEventListener("DOMContentLoaded", fn);
    })();
    """
end

const BUNDLE_BOKEH_CDN = (
    js_urls = [
        "https://cdn.bokeh.org/bokeh/release/bokeh-2.4.2.min.js",
        "https://cdn.bokeh.org/bokeh/release/bokeh-gl-2.4.2.min.js",
        "https://cdn.bokeh.org/bokeh/release/bokeh-widgets-2.4.2.min.js",
        "https://cdn.bokeh.org/bokeh/release/bokeh-tables-2.4.2.min.js",
        "https://cdn.bokeh.org/bokeh/release/bokeh-mathjax-2.4.2.min.js",
    ],
    css_urls = [],
    js_raw = [],
    css_raw = [],
)

const BUNDLE_BOKEH_CDN_NOMIN = (
    js_urls = [
        "https://cdn.bokeh.org/bokeh/release/bokeh-2.4.2.js",
        "https://cdn.bokeh.org/bokeh/release/bokeh-gl-2.4.2.js",
        "https://cdn.bokeh.org/bokeh/release/bokeh-widgets-2.4.2.js",
        "https://cdn.bokeh.org/bokeh/release/bokeh-tables-2.4.2.js",
        "https://cdn.bokeh.org/bokeh/release/bokeh-mathjax-2.4.2.js",
    ],
    css_urls = [],
    js_raw = [],
    css_raw = [],
)
