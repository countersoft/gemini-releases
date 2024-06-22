$(document).ready(function () {
        var QuickEntry =
        {
            options: null,
            init: function()
            {
                QuickEntry.options = {
                    classes: {
                        textContainer: "limTextContainer"
                    },
                    debug: false,
                    sortableOptions: {
                        disableNesting: 'no-nest',
                        forcePlaceholderSize: true,
                        handle: 'div',
                        helper: 'clone',
                        items: 'li',
                        maxLevels: 5,
                        opacity: .6,
                        placeholder: 'drag-placeholder',
                        revert: 250,
                        tabSize: 25,
                        tolerance: 'pointer',
                        toleranceElement: '> div'
                    },
                    events: {
                        onAddText: function () { }
                    }
                };

                $('#QuickEntry .sortable').nestedSortable(QuickEntry.options);

                $('#QuickEntry #Projects').change(function () {
                    QuickEntry.updateAppNavCard();
                });

                QuickEntry.generate($('#QuickEntry #items'));

                $('#QuickEntry #createItems').click(function () {

                    if ($('#QuickEntry .limTextContainer input').val() != '')
                    {
                        var keyEvent = jQuery.Event("keydown");
                        keyEvent.keyCode = 13;
                        $('#QuickEntry .limTextContainer input').trigger(keyEvent);
                    }

                    var data = QuickEntry.data();

                    if (data.length >= 2 || data[0].children.length > 0)
                    {
                        gemini_ui.startBusy('#QuickEntry #createItems');

                        gemini_ajax.postCall('apps/QuickEntry', "createissues", function (data) {
                            if (data.success) {
                                gemini_notifications.fetch();
                                setTimeout(function () { gemini_notifications.hide(); }, 3000);
                                QuickEntry.reset();
                            }
                            gemini_ui.stopBusy('#QuickEntry #createItems');

                        },
                        function (data) {
                            gemini_ui.stopBusy('#QuickEntry #createItems');
                        },
                        {
                            items: JSON.stringify(data),
                            projectId: $('#QuickEntry #Projects').val()
                        });
                    }
                });
                
            },
            generate: function (root)
            {
                QuickEntry.initRoot = root;
                root.empty();

                var ol = $("<ol data-key='root' class='sortable'></ol>");

                ol.appendTo(root);

                var li = $("<li id='limItem_1'><div class='" + QuickEntry.options.classes.textContainer + "'>" + QuickEntry.textHtml() + "</div></li>").appendTo(ol);

                $("input", li).bind('keydown.additems', function (e) {
                    QuickEntry.keyDown(e, li);
                });

                ol.nestedSortable(QuickEntry.options.sortableOptions);
                QuickEntry._focus(li);
            },
            initRoot: null,
            reset: function ()
            {
                QuickEntry.initRoot.empty();
                QuickEntry.generate(QuickEntry.initRoot);
            },
            nextId: 2, //default node is 1, therefore next is 2            
            textHtml: function ()
            {
                var s = "<div class='" + QuickEntry.options.classes.textContainer + "'><input type='text' class='input-title' maxlength='255' placeholder='Title'/></div>";
                return s;
            },
            createNode: function (sibling)
            {
                var li = $("<li id='limItem_" + QuickEntry.nextId + "'>" + QuickEntry.textHtml() + "</li>");
                QuickEntry.nextId++;
                sibling.after(li);

                var tb = li.children("div").children("input");

                QuickEntry._bindTextboxEvents(tb, li);
                tb.focus();
            },
            convertTextbox: function (li)
            {    
                var text = $(".input-title", li);

                if (text.val() == "") {
                    //Empty, remove li
                    if ($("ol[data-key='root']").find("li").length > 1) {
                        if (li.find("li").length == 0) {
                            li.remove(); //don't remove the only one there.
                        }
                    }
                    return false;
                }

                li.children("div").remove();
                li.prepend('<div><span class="fonticon-drag-handle valign-text-bottom margin-right-5" style="color:#C4C4C4;"></span>' + text.val() + '</div>');

                QuickEntry.options.events.onAddText();

                li.children("div").bind("click.edititem", function (e)
                {
                    QuickEntry._edit(li);
                    e.preventDefault();
                });

                return true;
            },
            _rebind: function ()
            {
                $("ol[data-key='root']").nestedSortable('destroy');
                $("ol[data-key='root']").nestedSortable(QuickEntry.options.sortableOptions);
            },
            _edit: function (li)
            {
                var text = li.children("div").text();
                var textBox = $("<div class='" + QuickEntry.options.classes.textContainer + "'>" + QuickEntry.textHtml() + "</div>");
                li.children('div').remove();
                li.prepend(textBox);

                var tb = textBox.find("input");
                QuickEntry._bindTextboxEvents(tb, li);
                tb.val(text).focus();;
                QuickEntry._focus(li);

            },
            indent: function (li) {
                var prevSibling = li.prev('li');
                if (!prevSibling || prevSibling == "undefined" || prevSibling.length == 0)
                    return;

                var ol = prevSibling.children("ol");

                if (!ol || ol == "undefined" || ol.length == 0) {
                    prevSibling.append("<ol></ol>");
                    ol = prevSibling.children("ol");
                }

                ol.append(li);

                QuickEntry._rebind();

                ol.find("input").focus();

                QuickEntry._focus(li);

            },
            outdent: function (li)
            {
                var parent = li.parent().closest("li");

                if (!parent || parent == "undefined" || parent.length == 0)
                    return;

                parent.after(li);
                $("input", li).focus();
                QuickEntry._rebind();
                QuickEntry._focus(li);
            },
            _previous: function (li)
            {
                //get all nodes
                var root = $("ol[data-key='root']");
                var nodes = root.find("li");
                var $prev = $(nodes[nodes.index(li) - 1]);
                QuickEntry._edit($prev);
            },
            _next: function (li)
            {
                var root = $("ol[data-key='root']");

                var nodes = root.find("li");

                //check for end of array
                if (nodes.length - 1 <= nodes.index(li)) return;

                var $prev = $(nodes[nodes.index(li) + 1]);

                QuickEntry._edit($prev);
            },
            _focus: function (node)
            {
                node.find("input").focus();
                setTimeout(
                    function () {
                        var n = node.find("input");
                        n.focus();
                    }
                    , 100);
            },
            _bindTextboxEvents: function (tb, li)
            {
                li = tb.closest("li");
                tb.bind('keydown.additems', function (e)  {
                    QuickEntry.keyDown(e, li);
                }).bind('blur.additems', function (e) {
                    var root = $("ol[data-key='root']");
                    if (root.find("input").length > 1) {
                        QuickEntry.convertTextbox(tb.closest("li"));
                    }
                });
            },
            keyDown: function (e, node)
            {
                var keyCode = e.which != null ? e.which : e.keyCode;

                switch (keyCode)
                {
                    case 13:
                        if (QuickEntry.convertTextbox(node))
                            QuickEntry.createNode(node);
                        break;
                    case 9: //tab
                        if (e.shiftKey)
                            QuickEntry.outdent(node);
                        else
                            QuickEntry.indent(node);
                        e.preventDefault();
                        return false;

                    case 37://left
                        break;
                    case 38: //Up
                        QuickEntry._previous(node);
                        break;
                    case 39: //right
                        break;
                    case 40: //down
                        QuickEntry._next(node);
                        break;
                }
            },
            data: function ()
            {
                var root = $("ol[data-key='root']");
                var ret = QuickEntry._parseRoot(root);
                return ret;
            },
            _parseRoot: function (ol)
            {
                var ret = [];
                $.each(ol.children("li"), function (i, li) {
                    ret.push(QuickEntry._parseNode(li));
                });
                return ret;
            },
            _parseNode: function (li)
            {
                var root = $(li).children("ol");
                var children = [];
                if (root.length > 0)
                    children = QuickEntry._parseRoot(root);
                var ret = {
                    /*id: $(li).attr("id"),*/
                    text: $(li).children("div").text(),
                    children: children
                };
                return ret;
            },
            updateAppNavCard: function()
            {
                gemini_appnav.pageCard.Options['341532F1-55C4-4399-9458-9DD37B8D4237'] = JSON.stringify({ projectId: $('#Projects').val() });
            }
        };
        
        QuickEntry.init();        
});