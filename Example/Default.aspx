<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Example.Default1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>NomNoml .NET generator</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport" />
    <meta content="" name="description" />
    <meta content="Pedro Landeiroto" name="author" />

    <link href="~/assets/css/reset.css" rel="stylesheet" type="text/css" />
    <link href="~/assets/plugins/nom/css/nomnoml.css" rel="stylesheet" type="text/css" />
    <script src="https://code.jquery.com/jquery-1.11.2.min.js "></script>

    <script src="../../../assets/plugins/nom/lib/zepto.min.js"></script>
    <script src="../../../assets/plugins/nom/lib/underscore.js"></script>
    <script src="../../../assets/plugins/nom/lib/underscore.skanaar.js"></script>
    <script src="../../../assets/plugins/nom/lib/dagre.min.js"></script>
    <script src="../../../assets/plugins/nom/lib/skanaar.canvas.js"></script>
    <script src="../../../assets/plugins/nom/lib/vector.js"></script>
    <script src="../../../assets/plugins/nom/nomnoml.jison.js"></script>
    <script src="../../../assets/plugins/nom/nomnoml.parser.js"></script>
    <script src="../../../assets/plugins/nom/nomnoml.layouter.js"></script>
    <script src="../../../assets/plugins/nom/nomnoml.renderer.js"></script>

    <style>
        body {
            font-family: Calibri, Helvetica, sans-serif;
            font-weight: bold;
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <div style="color: #000; opacity: 0.8; margin-top:20px;margin-left:30px;">
            <h2>nomnoml .NET</h2>
        </div>
        <div style="margin-top: 20px;">

            <div id="wrap" style="height: 500px; width: 600px; background-color: #FDF6E3; margin: 0 auto; text-align: center;">
                <br />
                <canvas id="c"></canvas>
            </div>
        </div>

        <div style="margin: 0 auto; width: 500px; margin-top: 30px; text-align: center;">
                This is a simple .NET class library that helps to build the necessary syntax in code behind so that you can (re-)inject it into the page to draw (or redraw) the graph.
                This is somewhere between version 0.00000001 and 0.00000002 and it is still needing lots of fixes and improvements.<br /><br />

                All the merits go to the creator of NomNoml Library, you can check it in <a href="http://www.nomnoml.com/">nomnoml.com</a><br /><br />
                nomnoml .NET is available on <a href="http://github.com/pedrozok/NomNomlNet">Github</a>
            </div>

        <script>
            var nomnoml = nomnoml || {}

            var storage = buildStorage(location.hash)
            var jqCanvas = $('#c')
            var viewport = $(window)

            var canvasElement = document.getElementById('c')
            var graphics = skanaar.Canvas(canvasElement, {})

            window.addEventListener('resize', _.throttle(sourceChanged, 750, { leading: true }))

            if (storage.isReadonly) $('#storage-status').show()
            else $('#storage-status').hide()

            sourceChanged('[Nothing to show..]');

            nomnoml.discardCurrentGraph = function () {
                if (confirm('Do you want to discard current diagram and load the default example?')) {
                    sourceChanged()
                }
            }

            function setShareableLink(str) {
                var base = 'http://www.nomnoml.com/#view/'
                linkLink.href = base + str.split('\n').join('%0A').split(' ').join('%20')
            }

            function isViewMode(locationHash) {
            }

            function buildStorage(locationHash) {
                if (locationHash.substring(0, 6) === '#view/')
                    return {
                        read: function () { return decodeURIComponent(locationHash.substring(6)) },
                        save: function (source) { setShareableLink(textarea.value) },
                        isReadonly: true
                    }
                return {
                    read: function () { return localStorage['nomnoml.lastSource'] || defaultSource },
                    save: function (source) {
                        setShareableLink(textarea.value)
                        localStorage['nomnoml.lastSource'] = source
                    },
                    isReadonly: false
                }
            }

            function initImageDownloadLink(link, canvasElement) {
                link.addEventListener('click', downloadImage, false);
                function downloadImage() {
                    var url = canvasElement.toDataURL('image/png')
                    link.href = url;
                }
            }

            function getConfig(d) {
                return {
                    arrowSize: +d.arrowSize || 1,
                    bendSize: +d.bendSize || 0.3,
                    direction: { down: 'TB', right: 'LR' }[d.direction] || 'TB',
                    gutter: +d.gutter || 5,
                    edgeMargin: (+d.edgeMargin) || 0,
                    edges: { hard: 'hard', rounded: 'rounded' }[d.edges] || 'rounded',
                    fill: (d.fill || '#eee8d5;#fdf6e3;#eee8d5;#fdf6e3').split(';'),
                    fillArrows: d.fillArrows === 'true',
                    font: d.font || 'Calibri',
                    fontSize: (+d.fontSize) || 12,
                    leading: (+d.leading) || 1.25,
                    lineWidth: (+d.lineWidth) || 3,
                    padding: (+d.padding) || 8,
                    spacing: (+d.spacing) || 40,
                    stroke: d.stroke || '#33322E',
                    zoom: +d.zoom || 1
                }
            }

            function fitCanvasSize(rect, scale, superSampling) {
                var w = rect.width * scale
                var h = rect.height * scale
                jqCanvas.attr({ width: superSampling * w, height: superSampling * h })
                jqCanvas.css({
                    top: 300 * (1 - h / viewport.height()),
                    left: 150 + (viewport.width() - w) / 2,
                    width: w,
                    height: h
                })
            }

            function setFont(config, isBold, isItalic) {
                var style = (isBold === 'bold' ? 'bold ' : '')
                if (isItalic) style = 'italic ' + style
                graphics.ctx.font = style + config.fontSize + 'pt ' + config.font + ', Helvetica, sans-serif'
            }

            function parseAndRender(superSampling, text) {
                var ast = nomnoml.parse(text)
                var config = getConfig(ast.directives)
                var measurer = {
                    setFont: setFont,
                    textWidth: function (s) { return graphics.ctx.measureText(s).width },
                    textHeight: function (s) { return config.leading * config.fontSize }
                }
                var layout = nomnoml.layout(measurer, config, ast)
                fitCanvasSize(layout, config.zoom, superSampling)
                config.zoom *= superSampling
                nomnoml.render(graphics, config, layout, setFont)
            }

            function sourceChanged(text) {
                console.log(text);
                try {
                    var superSampling = window.devicePixelRatio || 1;
                    parseAndRender(superSampling, text)
                } catch (e) {
                    console.log(e);
                    var matches = e.message.match('line ([0-9]*)')
                    if (matches) {
                        var lineHeight = parseInt(jqTextarea.css('line-height'), 10)
                    }
                    else {
                        throw e
                    }
                }
            }

            //jQuery(document).ready(function () {
            //    sourceChanged('[a]->[b]\r\n[b]-->[c]');

            //});
        </script>
    </form>
</body>
</html>
