gemini_projectAdmin =
{
    executionUrl: '',
    currentProjectId: 0,
    pendingChanges: false,
    rowDragIndex: 0,
    init: function (versionId)
    {
        gemini_projectAdmin.attachProjectAttributeEvents();
        gemini_projectAdmin.currentProjectId = $('.projectAdmin #Projects1').val();

        $('.projectAdmin #Projects1').change(function ()
        {
            gemini_projectAdmin.currentProjectId = $(this).val();
            gemini_projectAdmin.refreshProjectAdmin();
        });

        $('#project-admin-content-pane').on("click", '.tab', gemini_projectAdmin.switchTab);
        gemini_projectAdmin.switchTab(null, $('.tab:first', '#project-admin-content-pane'));

        $('.projectAdmin').on("click", ".add-project-attribute", function (e)
        {
            gemini_commons.stopClick(e);

            var id = $(this).closest("tr").data("id");
            var projectId = $('.projectAdmin #Projects1').val();

            var successCallback = function ()
            {
                gemini_ui.htmlEditor('#project-attribute-value', null, null, false, 250, 549);

                $("#popup-button-yes", "#cs-popup-center").click(function (e)
                {
                    if ($('#project-attribute-form').valid())
                    {
                        gemini_projectAdmin.postCall("apps/projectAdmin/saveprojectattribute", null, function (response)
                        {
                            if (response.success)
                            {
                                $('#project-attribute-content .admin-datatable-holder').html(response.Result.Data.Html);
                                gemini_projectAdmin.attachProjectAttributeEvents();
                            }
                            
                            gemini_projectAdmin.popupClose();
                            gemini_ui.destroyHtmlEditor('#project-attribute-value');
                            $("#project-attribute-popup").remove();
                        }, null, $("#project-attribute-form").serialize(), null, true);
                    }
                })

                $("#popup-button-no", "#cs-popup-center").click(function (e)
                {                    
                    gemini_projectAdmin.popupClose();
                    gemini_ui.destroyHtmlEditor('#project-attribute-value');
                    $("#project-attribute-popup").remove();                    
                })
            }
            $("#cs-popup-center-content").css("height", '400px');
            gemini_projectAdmin.centerPopup("apps/projectAdmin/getprojectattributeeditor", null, { projectId: projectId, id: id }, null, "Save", "Close", false, false, successCallback, true);
        });

        $('.projectAdmin').on("click", "#project-attribute-table .action-button-delete", function (e)        
        {
            var tr = $(this).closest('tr');

            var id = tr.data('id');
            var name = tr.find('.name').text();

            gemini_commons.translateMessage("[[Delete]] " + name + " ?", ['Delete'], function (message)
            {
                gemini_popup.modalConfirm(message, null,
                    function ()
                    {
                        gemini_projectAdmin.postCall("apps/projectAdmin/deleteprojectattribute", null, function (response)
                        {
                            if (response.success)
                            {
                                $('#project-attribute-table #row-' + response.Result.Data.Id).remove();
                            }

                            gemini_projectAdmin.popupClose();
                        }, null, { id: id }, null, true);
                    }
                );
            });

        })
    },
    refreshProjectAdmin: function (response)
    {
        var card = $.parseJSON(gemini_commons.htmlDecode(gemini_appnav.pageCard.Options['A39E2E45-1D92-4333-A0A9-C60AF393C52B']));

        card.PageData = { projectId: parseInt(gemini_projectAdmin.currentProjectId)};

        gemini_appnav.pageCard.Options['A39E2E45-1D92-4333-A0A9-C60AF393C52B'] = gemini_commons.htmlEncode(JSON.stringify(card));

        gemini_ui.stopBusy('#modal-confirm #modal-button-yes');
        gemini_ajax.call("apps/projectAdmin", "getprojectadmin", function (response)
        {
            if (response.Result.Data.success)
            {
                $('#view-permission').replaceWith(response.Result.Data.permission);
                $('#view-groups').replaceWith(response.Result.Data.groups);
                $('#project-attribute-table').parent().replaceWith(response.Result.Data.attributes);

                gemini_projectAdmin.attachProjectAttributeEvents();
            }
            gemini_ui.stopBusy('#modal-confirm #modal-button-yes');
        }, function (error) { gemini_ui.stopBusy('#modal-confirm #modal-button-yes'); }, { projectId: gemini_projectAdmin.currentProjectId });
    },
    attachProjectAttributeEvents: function () {
        var params = $.extend({},
        {
            bFilter: false,
            bInfo: true,
            bSort: true,
            bPaginate: false,
            bLengthChange: false,
            iDisplayLength: 20,
            sPaginationType: "full_numbers",
            "oLanguage": {
                "sInfo": "Showing _START_ to _END_ of _TOTAL_ entries",
                "sInfoEmpty": ""
            },
            "aoColumnDefs": [{
                "bSortable": false,
                "aTargets": [0,3]
            }]
        });

        $('#project-attribute-table').dataTable(params);

        $('#project-attribute-table').tableDnD({
            dragHandle: ".dragHandle",
            onDrop: function (table, row)
            {
                gemini_projectAdmin.postCall('apps/projectAdmin', '/resequenceAttribute', function () { }, null, {
                    projectId: gemini_projectAdmin.currentProjectId,
                    id: $(row).data('id'),                    
                    afterid: row.rowIndex == 1 ? 0 : $(table.rows[row.rowIndex - 1]).data('id'),
                    newIndex: row.rowIndex - 1,
                    oldIndex: gemini_projectAdmin.rowDragIndex - 1
                }, null, true);
                
            },
            onDragStart: function (table, row)
            {
                gemini_projectAdmin.rowDragIndex = row.parentNode.parentNode.rowIndex;                
            },
            onDragClass: 'highlight-hover',
            onAllowDrop: function (draggedRow, dropTargetRow)
            {                
                return $(dropTargetRow.children[0]).is('td');
            }
        });
    },
    centerPopup: function (controller, method, params, extra, actionButtonText, cancelButtonText, hideActionButton, hideCancelButton, successCallback, ignoreContainer) {
        
        if (!actionButtonText)
        {
            actionButtonText = "Save";
        }

        if (!cancelButtonText)
        {
            cancelButtonText = "Cancel";
        }

        $("#popup-button-yes", "#cs-popup-center").show();
        $("#popup-button-no", "#cs-popup-center").show();

        //ensure that all events are unbound before showing the new popup.
        $("#popup-button-yes", "#cs-popup-center").unbind();
        $("#popup-button-no", "#cs-popup-center").unbind();
        
        $("#popup-button-yes", "#cs-popup-center").attr("value", actionButtonText);
        $("#popup-button-no", "#cs-popup-center").attr("value", cancelButtonText);

        if (hideActionButton) $("#popup-button-yes", "#cs-popup-center").hide();
        if (hideCancelButton) $("#popup-button-no", "#cs-popup-center").hide();

        gemini_ajax.call(controller, method, function (response) {
            if (response.Success) {
                gemini_projectAdmin.showCenterPopup(response);
                
                if (successCallback != null && successCallback != undefined) successCallback(response);
            }
        }, null, params, extra, ignoreContainer);        
        
    },
    showCenterPopup: function (response)
    {
        if (response.success) {
            $("#cs-popup-center").css("display", "inline-block"); //get width correctly and needs to be BEFORE we insert the data

            var div = $("#cs-popup-center-content");
            if (response.Result == undefined)
                div.html(response);
            else
                div.html(response.Result.Data.Html);
            $("#cs-popup-center-buttons").css("top", "auto");
                        
            var height = $("#cs-popup-center-content").height() + $("#cs-popup-center-buttons").height() + 50;
            var width = $("#cs-popup-center-content").width() + 20;
            $("#cs-popup-center-buttons").css("top", $("#cs-popup-center-buttons").position().top + "px");
            $("#cs-popup-center").css("display", "block"); //ensure the div stays this width if content inside is changed
            var params = {
                inline: true,
                href: "#cs-popup-center",
                transition: "none",
                width: Math.max(width, 300) + "px",
                height: Math.max(height, 80) + "px",
                overlayClose: false,
                escKey: false,
                opacity: '0.8'
            };
            $.colorbox(params);

            $("#cs-popup-center-content input[type='text']:first").focus();
            $("#cs-popup-center-content input[type='text']:first").click(); //If first item is a calender then it will pop out the calender as well

            gemini_keyboard.bindEscape("#colorbox #popup-button-no");
        }

    },
    postCall: function (controller, method, callback, badCall, params, extra, ignoreContainer)
    {
        /*if (gemini_ajaxXHR != undefined && gemini_ajaxXHR != null) {
            ajaxXHR.abort();
        }*/

        gemini_session.isResetSession(controller, method);

        var url = gemini_ajax.getUrl(controller, method, ignoreContainer);

        return $.ajax({
            type: "POST",
            url: url,
            data: params,
            //dataType: "json",
            success: function (data)
            {
                if (callback != null && callback != undefined && typeof callback == 'function')
                {
                    if (extra != null && extra != undefined)
                    {
                        callback.call(this, data, extra);
                    }
                    else
                    {
                        callback.call(this, data);
                    }
                }
                ajaxXHR = null;
            },
            error: function (xhr, ajaxOptions, thrownError)
            {
                gemini_diag.log('FAILED, Status=' + xhr.status + ' -> ' + thrownError);
                if (badCall != null && badCall != undefined && typeof badCall == 'function')
                {
                    badCall.call(this, xhr, ajaxOptions, thrownError);
                }
                ajaxXHR = null;
            }
        });
    },
    popupClose: function (e, extra)
    {
        if (e)
        {
            gemini_commons.stopClick(e);
        }

        $.colorbox.close();

        gemini_keyboard.unbindEscape("#colorbox #popup-button-no");

        //Unbind all events to the buttons
        $("#popup-button-yes", "#cs-popup-center").unbind();
        $("#popup-button-no", "#cs-popup-center").unbind();
        $("#cs-popup-center").css("display", "none");
    },
    SaveConfigScreen: function ()
    {
        var groupIds = $('#groupIds').val();
        var userGroupIds = $('#userGroupIds').val();

        gemini_ajax.postCall("apps/projectAdmin", "saveconfigpage",
        function (response)
        {

        }, null, { groupIds: groupIds, userGroupIds: userGroupIds }, null, true);

        gemini_ajax.postCall("configure/tab/apps/permissions", "save",
        function (response)
        {
            gemini_popup.toast("Saved")
        }, null, $('#app-security-form').serialize(), null, true);
    },
    switchTab: function (e, elem)
    {
        var _that = this;
        if (elem != null && elem != undefined)
        {
            _that = elem;
        }
        $('.tab', '#project-admin-content-pane').removeClass('selected').addClass('normal');
        $('.tab-content', '#project-admin-content-pane').hide();
        var content = $('#' + $(_that).attr('data-contentid'));
        content.show();
        $("input[type='text']:first", content).focus();
        $(_that).removeClass('normal').addClass('selected');
        //gemini_item.setContentHeight();

    }
};