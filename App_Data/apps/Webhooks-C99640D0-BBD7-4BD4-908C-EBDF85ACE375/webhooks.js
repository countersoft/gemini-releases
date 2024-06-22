webhooks = {
    init: function() {
            gemini_ui.fancyInputs('#table-admin-webhooks .fancy');
            webhooks.initDatatablesWithEdit("#table-admin-webhooks", { "aoColumnDefs": [{ "bSortable": false, "aTargets": [4]}] });
            $('#action-button-save','#table-admin-webhooks').click(function(){
                gemini_ajax.postCall("apps/webhooks", "save", function (response) {
                    if(!response.success) {
                        gemini_popup.toast(response.Message, true);
                        return;
                    }
                gemini_popup.toast("Saved");
                gemini_admin.getPage();
            }, null, {
                        Description: $('#Description', '#table-admin-webhooks').val(), 
                        Url: $('#Url', '#table-admin-webhooks').val(), 
                        Create: $('#Create', '#table-admin-webhooks').prop('checked'), 
                        Update: $('#Update', '#table-admin-webhooks').prop('checked')
                    }, null, true);
            });

            $('#table-admin-webhooks').off('click', '.action-button-delete').on('click', '.action-button-delete', function(){
                var that=$(this);
                gemini_popup.modalConfirm("Are you sure that you want to delete " + that.parent().parent().data('id') + "?", null, function () {
                    gemini_ui.startBusy('#colorbox2 #modal-confirm #modal-button-yes');
                        gemini_ajax.postCall("apps/webhooks", "delete", function () {
                            gemini_admin.removeRow(that);
                            gemini_ui.stopBusy('#modal-confirm #modal-button-yes');
                        }, function () { gemini_ui.stopBusy('#modal-confirm #modal-button-yes'); }, {
                                    Url: that.parent().parent().data('id')
                                }, null, true);
                        });
                });
        },

    initDatatablesWithEdit: function (selector, options)
    {
        var optionsString = {};

        var editSelector = "tbody td:not([data-edit='false'])";

        if (options != null) optionsString = options;

        var params = $.extend({},
            {
                bFilter: true,
                bInfo: true,
                bSort: true,
                bPaginate: true,
                bLengthChange: false,
                iDisplayLength: 20,
                sPaginationType: "full_numbers",
                "oLanguage": {
                    "sInfo": "Showing _START_ to _END_ of _TOTAL_ entries",
                    "sInfoEmpty": "No data."
                },
                fnDrawCallback: function (value, y) {

                    $(selector + ' ' + editSelector).editable(csVars.Url + 'apps/webhooks/saveproperty', {
                        placeholder: '',
                        detectType: function (elem) {
                            var th = gemini_ui.getTableTHForTD(elem);
                            return $(th).data('edit-type');
                        },
                        validationRequired: function (elm) {
                            var th = gemini_ui.getTableTHForTD(elm);
                            return $(th).data('required');
                        },
                        validationEmail: function (elm) {
                            var th = gemini_ui.getTableTHForTD(elm);
                            return $(th).data('email');
                        },
                        validationProgrammaticalNames: function (elm) {
                            var th = gemini_ui.getTableTHForTD(elm);
                            return $(th).data('programmaticalnames');
                        },
                        loadurl: csVars.Url + 'apps/webhooks/getproperty',
                        loaddata: function () {
                            var th = gemini_ui.getTableTHForTD(this);
                            var field = $(th).data('field');
                            return {
                                id: $(this).parent().data('id'),
                                property: field
                            };
                        },
                        submitdata: function () {
                            var th = gemini_ui.getTableTHForTD(this);
                            var field = $(th).data('field');
                            return {
                                id: $(this).parent().data('id'),
                                property: field
                            };
                        },
                        "height": "14px"
                    });
                }
            }, optionsString);

       gemini_admin.currentTable = $(selector).dataTable(params);
    },
};