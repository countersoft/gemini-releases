var breezeReply = {
    init: function (id, timestamp) {
    
        gemini_ui.templatedContentPlugin( gemini_ui.templateContentAreas.Breeze, 0, id, function() {
            gemini_ui.htmlEditor("#breeze-comments-wysiwyg-content", null, function (ed) {
                if (ed.type == 'change') {
                    gemini_edit.pendingHtmlChanges = true;
                }
            }, undefined, undefined, undefined, 'templatedcontent_4');
        });
        
        gemini_ui.chosen("#breeze-visibility");
        gemini_ui.chosen(".breeze-comments-form #From");
        window.onbeforeunload = gemini_edit.warnLoseChanges;

        var options = {
            dataType: "json",
            success: function (response, statusText, xhr, $form) {
                if (response.success) {
                    gemini_ui.destroyHtmlEditor("#breeze-comments-wysiwyg-content");
                    gemini_ui.destroyHtmlEditor("#comments-wysiwyg-content");
                    gemini_ui.destroyHtmlEditor("#comments-wysiwyg-content2");
                    gemini_item.replaceContent(response);
                    gemini_item.getAppControlValue(id, '4192EAA7-9D09-4E36-97C3-64FCE039EDB4', 'BCADBC94-44C0-4116-8008-5A57F26E6573', 'value', '');
                    gemini_popup.toast("Sent");
                    gemini_ui.stopBusy('.breeze-comments-wysiwyg-container:eq(0) .breeze-cs-comment-add-save');
                    gemini_edit.pendingHtmlChanges = false;
                }
                else {
                    breezeReply.reportError(response.Message);
                }
            },
            error: function (response) {
                breezeReply.reportError(response.Message);
            }

        };
        $(".breeze-comments-form").ajaxForm(options);

        $('.breeze-cs-comment-add-save', '.breeze-comments-wysiwyg-container').click(function (e) {
            e.preventDefault();
            tinyMCE.get('breeze-comments-wysiwyg-content').save(); // iOS 9 fix
            if ($(this).parents(".breeze-comments-wysiwyg-container").find($(".wysiwyg-container textarea")).val() == "") {
                $(this).parents(".breeze-comments-wysiwyg-container").find($(".wysiwyg-container .mce-tinymce")).addClass('error');
            }
            else {
                if ($('#breeze-to').val() != '') {
                    gemini_ui.startBusy('.breeze-comments-wysiwyg-container:eq(0) .breeze-cs-comment-add-save');
                    gemini_ajax.postCall("apps/breeze/",
                        "checkupdates/" + id,
                        function(response) {
                            if (response.success && response.Result.Data.numberUpdates > 0) {
                                $("#new-changes-panel").html(response.Result.Data.html).slideDown();
                                timestamp = response.Result.Data.utcTimestamp; //reset the time to ignore those changes
                                gemini_ui.stopBusy('.breeze-comments-wysiwyg-container:eq(0) .breeze-cs-comment-add-save');

                            } else {
                                $('.breeze-comments-form').submit();
                            }
                        },
                        null,
                        { sinceWhenUtc: timestamp},
                        null,
                        true);
                }
                else {
                    $('#breeze-to').addClass('error');
                }
            }
        });

        $("#breeze-reply-clickzone").click(function (e) {
            if ($("#breeze-reply-expander").hasClass("fonticon-arrow-down"))
            {
                $("#breeze-reply-expander").addClass("fonticon-arrow-up").removeClass("fonticon-arrow-down");
            }
            else
            {
                $("#breeze-reply-expander").addClass("fonticon-arrow-down").removeClass("fonticon-arrow-up");
            }
            
            $("#breeze-reply-changes").slideToggle('fast');
        });

        setTimeout(function() { $('#4192EAA7-9D09-4E36-97C3-64FCE039EDB4-BCADBC94-44C0-4116-8008-5A57F26E6573 button:last span').remove();}, 500);

    },
    reportError: function (text) {
        if (text != null && text != undefined && text.length > 0) {
            gemini_popup.toast(text, true);
        }
        else {
            gemini_popup.toast("Errors occurred when sending the email to the client.", true);
        }
        gemini_ui.stopBusy('.breeze-comments-wysiwyg-container:eq(0) .breeze-cs-comment-add-save');

    },

    mergeTicketsData : [],

    initMerge: function (id, key, links) {

        gemini_ui.fancyInputs('#breeze-merge-link');
        gemini_ui.chosen("#breeze-merge-linkName");

        gemini_ui.fancyInputs('#breeze-merge-status');
        gemini_ui.chosen("#breeze-merge-statusName");

        $('#breeze-merge-main').on('ifChanged', '#breeze-merge-link', function (e) {
            if($('#breeze-merge-link').prop('checked')) {
                $('#merge-link-dropdwon').removeClass('invisible');
            }
            else {
                $('#merge-link-dropdwon').addClass('invisible');
            }
        });

        $('#breeze-merge-main').on('ifChanged', '#breeze-merge-status', function (e) {
            if($('#breeze-merge-status').prop('checked')) {
                $('#merge-status-dropdwon').removeClass('invisible');
            }
            else {
                $('#merge-status-dropdwon').addClass('invisible');
            }
        });

        $('#breeze-merge-submit').click(function(){
            if(breezeReply.mergeTicketsData.length == 0) return;
            var url = gemini_ajax.getUrl('apps/breeze/merge/'+ id,  '',  true);

            gemini_ui.startBusy('#breeze-merge-submit');
            $.ajax({
                type: "POST",
                url: url,
                dataType: "json",
                data: JSON.stringify({merge: _.pluck(breezeReply.mergeTicketsData, 'IssueKey'), link: $('#breeze-merge-link').prop('checked'), linkName: $('#breeze-merge-linkName').val(), status: $('#breeze-merge-status').prop('checked'), statusName: $('#breeze-merge-statusName').val()}),
                contentType: 'application/json; charset=utf-8',                
                success: function (response) {
                    if (response.Success)
                    {
                        gemini_commons.refreshPage();
                    }
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    var x=1;
                }
            });
        });

        $("#breeze-merge-input").autocomplete({
            source: function (request, response) {
                gemini_ajax.call("item", "getissuesdropdown?issueid=" + id,
                    function (data) {
                        var rows = new Array();
                        for (var i = 0; i < data.Result.Data.length; i++) {
                            rows[rows.length] = { label: data.Result.Data[i].value + " - " + data.Result.Data[i].label, value: data.Result.Data[i].value };
                        }
                        response(rows);
                    }, null, { term: request.term });
            },
            minLength: 2,
            width: 200,
            dataType: "json",
            matchContains: "word",
            autoFill: false,
            select: function (e, data) {
                if(data.item.value == key ||  _.find(breezeReply.mergeTicketsData, function(ticket) {
                    return ticket.ItemKey == data.item.value;
                }) != undefined) {
                    $("#breeze-merge-input").addClass('error');
                    return false;
                }

                if(_.find(links, function(link) {
                    return link == data.item.value;
                    }) != undefined) {
                    $("#breeze-merge-input").addClass('error');
                    return false;
                }

                $("#breeze-merge-input").removeClass('error');
                breezeReply.mergeTicketsData.push({ IssueKey: data.item.value, IssueTitle: data.item.label });
                breezeReply.renderMerge();
                $('#breeze-merge-input').val('');
                return false;
            }
        });
    },

    renderMerge: function() {
        $('#merge-tickets-data').empty();
        for (var i = 0; i < breezeReply.mergeTicketsData.length; i++) {
            $('#merge-tickets-data').append('<div id="'+ breezeReply.mergeTicketsData[i].IssueKey + '">' + breezeReply.mergeTicketsData[i].IssueTitle + '</div>');
        }
    },

    getCannedResponse: function(editor, id) {
        gemini_ajax.call("apps/breeze", "cannedresponse/" + gemini_item.issueId + "/" + id,
            function (data) {
                editor.insertContent(data);
            }, null, null, null, true);
    }
}

//# sourceURL=breeze.js
