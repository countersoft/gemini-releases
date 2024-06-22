admin_audit_app = {
    currentListValues: null,
    init: function () {
        admin_audit_app.initDataTables();
        admin_audit_app.attachFilterEvents();
    },
    initDataTables: function()
    {
        $('#table-admin-audit .action-button-edit').click(function () {
            var id = $(this).data('id');
            gemini_popup.modalConfirm("Revert change?", null,
                function () {
                    gemini_ui.startBusy('#modal-confirm #modal-button-yes');

                    gemini_ajax.postCall("apps/AdminAudit", "rollback",
                        function (response) {
                            if (response.Success) {
                                gemini_popup.toast("Changes reverted");
                                $('#table-admin-audit #row-' + id).remove();
                            }

                            gemini_ui.stopBusy('#modal-confirm #modal-button-yes');
                        }, function () { gemini_ui.stopBusy('#modal-confirm #modal-button-yes') }, { id: id }, null, true);
                }
            );

        });

        var params = $.extend({},
        {
            bDestroy: true,
            bFilter: true,
            bInfo: true,
            bSort: true,
            bPaginate: true,
            bLengthChange: false,
            iDisplayLength: 20,
            sPaginationType: "full_numbers",
            "oLanguage": {
                "sInfo": "Showing _START_ to _END_ of _TOTAL_ entries",
                "sInfoEmpty": ""
            },
            "aaSorting": []
        });

        gemini_admin.currentTable = $('#table-admin-audit').dataTable(params);
    },
    executeFilter: function()
    {
        gemini_ajax.postCall("apps/AdminAudit", "getdata",
            function (response) {
                if (response.Success) {
                    var filter = $('#filter-container');

                    if (gemini_admin.currentTable) gemini_admin.currentTable.fnDestroy();
                    $('#table-admin-audit').replaceWith(response.Result.Data.html);

                    admin_audit_app.initDataTables();

                    $("#table-admin-audit_wrapper").prepend(filter);
                   
                    $('#filter-container #userids_chosen').remove();
                    gemini_ui.chosen('#filter-container select', "", true);

                    admin_audit_app.attachFilterEvents();
                }

                gemini_ui.stopBusy('#modal-confirm #modal-button-yes');
            }, function () { gemini_ui.stopBusy('#modal-confirm #modal-button-yes') }, $('#filter-container .filter-form').serialize(), null, true);
    },
    attachFilterEvents: function ()
    {
        $('.options', '#filter-container').click(function (e) {
            e.stopPropagation();
            e.preventDefault();
        });

        $('.control-icon', '#filter-container').click(function () {
            var _this = $(this);
            var options = _this.find('+ .options');

            if (options.is(":visible")) {
                options.hide();
                gemini_keyboard.unbindEscape("#page-options-box .options");
            }
            else {
                options.show();
                gemini_keyboard.bindEscape("#page-options-box .options", function () { $('#page-options-box .options').hide(); });
            }

            options.position({
                "of": _this,
                "my": "right top",
                "at": "right bottom",
                "offset": "0 0",
                "collision": "none"
            });
        });

        gemini_ui.datePicker('#filter-container .datepicker', function () { admin_audit_app.executeFilter() });

        $('#filter-container .datepicker').change(function () { admin_audit_app.executeFilter(); });
        $('#filter-container #filter-by-user').click(function () {
            admin_audit_app.executeFilter();
            $('#page-options-box .options').hide();
        });

        $('#filter-container #userids').change(function () {
            var value = $('#userids').val();
            var any = $('option:first', $('#userids')).val();
            if (value != null && value != undefined && value.length > 1 && value.indexOf(any) != -1) {
                if (admin_audit_app.currentListValues != null && admin_audit_app.currentListValues != undefined && admin_audit_app.currentListValues.indexOf(any) != -1) {
                    var newSelected = $('#userids').val();
                    newSelected.splice(0, 1);
                    $('#userids').val(newSelected);
                }
                else {
                    $('#userids').val(any);
                }
            }
            else if (value == null || value == undefined) {
                $('#userids').val(any);
            }

            gemini_ui.chosenUpdate($('#userids'));
            admin_audit_app.currentListValues = $('#userids').val();
        });
    }
}