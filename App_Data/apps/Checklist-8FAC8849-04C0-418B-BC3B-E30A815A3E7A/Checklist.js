checklist_app = {
    refreshTable: function () {
        gemini_ajax.postCall("apps/Checklist", "getpage",
        function (response) {
            if (response.success) {
                $('.admin-datatable-holder').html(response.Result.Data);
                $('#checklist-title').val("");
            }
        }, null, { templateId: $('#Template').val() }, null, true);
    },
    postNewItem: function () {
        if ($('#checklist-title').val() == "") return;

        gemini_ajax.postCall("apps/Checklist", "add",
            function (response) {
                if (response.success) {
                    checklist_app.refreshTable();
                }
            }, null, { title: $('#checklist-title').val(), templateId: $('#Template').val() }, null, true);
    }
}