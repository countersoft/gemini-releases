app_repeating = {
    popupContainer: '#cs-popup',
    formContainer: '#cs-popup-content',
    pendingChanges: false,
    itemId: '',
    init: function ()
    {
        $.subscribe('items-grid-filter-executed', function () {
            app_repeating.refreshItemGrid();            
            $('#items-grid').css('opacity', '1');
        });

        if ($('#page-content-zone .items-data-container').length > 0) {        
            app_repeating.resizeMainItemsGrid();
            $(window).resize(function () {
                app_repeating.resizeMainItemsGrid();
            });
        }

        $('#app-repeating #create').click(function () {
            var currentRow = $(this).parents('tr:eq(0)');

            var itemId = currentRow.data('id');
            var startDate = $('#start_date', currentRow).val();
            var endDate = $('#end_date', currentRow).val();

            if (startDate == '')
                $('#start_date', currentRow).addClass('error')
            else
                $('#start_date', currentRow).removeClass('error')

            if (endDate == '')
                $('#end_date', currentRow).addClass('error')
            else
                $('#end_date', currentRow).removeClass('error')

            var checkedItems = $('#app-repeating #items .item_checkboxes:checked');

            if (checkedItems.length == 0)
            {
                gemini_popup.toast("Check at least one item", true);
            }

            if (startDate != '' && endDate != '' && checkedItems.length > 0)
            {
                var itemIds = [];

                checkedItems.each(function (index, key) {
                    itemIds.push($(key).val());
                });
               
                gemini_ajax.postCall("apps/Repeater", "create", CreateResponse, null, { itemIds: itemIds, startdate: startDate, endDate: endDate }, null, true);
            }
        })

        function CreateResponse(response) {
            if (response.success) {
                $.each(response.Result.Data.issueLastRepeatedDate, function (key, value) {
                    $('.lastCreatedColumn', $('#app-repeating #item-' + key)).text(value);
                });
                
                $('#app-repeating #items input[type="checkbox"]').prop('checked', false);

                gemini_popup.toast('Items Created');
            }
            else {
                gemini_popup.toast(response.Message, true);
            }
        }

        $('#app-repeating .edit').click(function (e) {
            e.preventDefault();
            app_repeating.itemId = $(this).closest('tr').data('issue-id');         
            
            gemini_ajax.postCall('item', "edit?viewtype=0", app_repeating.showEditingPopup, null, { id: app_repeating.itemId}, setTimeout(function () { $("#Repeat_Interval").focus(); }, 200));
        });

        $('#app-repeating .schedule').click(function (e) {
            e.preventDefault();
            app_repeating.itemId = $(this).closest('tr').data('issue-id');

            $("#cs-popup-center-content").css("width", "380px");
            $("#cs-popup-center-content").css("height", "150px");
            gemini_popup.centerPopup("apps/Repeater", "popup?itemId=" + app_repeating.itemId, null, null, "Generate");
        });

        $('#tabledata').on('click', '.expander', function (e) {
            gemini_commons.stopClick(e);
            var id = $(this).closest('tr').data('issue-id');

            if ($(this).hasClass('fonticon-arrow-down'))
            {               
                $('#app-repeating .repeat-of-' + id).show();
                $(this).removeClass('fonticon-arrow-down');
                $(this).addClass('fonticon-arrow-up');
            }
            else
            {
                $('#app-repeating .repeat-of-' + id).hide();

                $(this).removeClass('fonticon-arrow-up');
                $(this).addClass('fonticon-arrow-down');
            }
        });
    },
    showEditingPopup: function (response, elem) {
        if (typeof response == 'object') {
            if (!response.success) return;
        }

        //gemini_edit.triggerXHR = null;
        //gemini_edit.clickedElement = elem;
        try { $('#cs-popup-content', app_repeating.popupContainer).html(response); } catch (e) { }

        gemini_ui.datePicker('#cs-popup-content .datepicker');
        //$('select', '#cs-popup-content').chosen({ stay_open : true, topmost_container: '#cs-popup-content .jspPane:first' });
        gemini_ui.chosen('#cs-popup-content select:not(.no-chosen)', '#cs-popup-content .jspPane:first', false);
        gemini_ui.ajaxChosen('#cs-popup-content select.no-chosen.auto-complete-chosen', '#cs-popup-content .jspPane:first', false);

        $('#cs-popup-content', app_repeating.popupContainer).data("jsp", "");
        $(app_repeating.popupContainer).show();

        var availableHeight = gemini_sizing.availableHeight();
        //if(gemini_edit.pageType != gemini_commons.PAGE_TYPE.Item) availableHeight -= 200;
        $(app_repeating.popupContainer).css("height", availableHeight + 40);
        $(app_repeating.popupContainer).css("width", '820px');
        var contentHeight = availableHeight + 40 - $('#cs-popup-buttons').height() - 20;

        /***/
        var params = {
            inline: true,
            href: app_repeating.popupContainer,
            transition: "none",
            width: "820px",
            height: availableHeight + 40,
            overlayClose: false,
            escKey: false,
            opacity: '0.8',
            onComplete: function () {
                $(".checked-select").jScrollPane({});

                $("#cs-popup-content", app_repeating.popupContainer).jScrollPane({});
                $('.jspContainer', '#cs-popup-content').css("height", contentHeight);
                $('.jspPane', '#cs-popup-content').css("min-height", contentHeight - 10);
                gemini_ui.htmlEditor('.wysiwyg-editor', /*gemini_edit.onHtmlEditorInit*/null, app_repeating.setPendingChanges);
                gemini_ui.userAutocomplete('#cs-popup-content .user-autocomplete');
                $("#cs-popup-content", app_repeating.popupContainer).jScrollPane('reinitialise');
            }
        };
        $.colorbox(params);

        var options = {
            dataType: "json",
            success: function (responseText, statusText, xhr, $form) {
                if (responseText.success) {
                    app_repeating.pendingChanges = false;
                    app_repeating.hideEditingPopup();

                    app_repeating.refreshItemGrid();
                }
                else {
                    $('#server-validation-error', '#cs-popup').html(responseText.Message).show();
                }
                gemini_ui.stopBusy('#cs-popup #cs-popup-save');
            },
            error: function (e, data) {
                gemini_ui.stopBusy('#cs-popup #cs-popup-save');
                gemini_popup.toast("Item could not be created", true);
            }// post-submit callback   

        };
        $("#inline-edit-form", app_repeating.formContainer).ajaxForm(options);

        $("#inline-edit-form", app_repeating.formContainer).validate({
            ignoreTitle: true,
            submitHandler: function (form) {
                //gemini_edit.saveEditing();
                //$('#inline-edit-form', gemini_edit.formContainer).submit();
            }
        });

        //gemini_edit.editingMode = true;

        $('input', app_repeating.popupContainer).change(app_repeating.setPendingChanges);
        $('input[type=text]', app_repeating.popupContainer).keyup(app_repeating.setPendingChanges);
        $('select', app_repeating.popupContainer).change(app_repeating.setPendingChanges);
        $("#cs-popup-save", app_repeating.popupContainer).unbind("click");
        $("#cs-popup-close", app_repeating.popupContainer).unbind("click");

        $("#cs-popup-save", app_repeating.popupContainer).click(app_repeating.saveEditing);
        $("#cs-popup-close", app_repeating.popupContainer).click(app_repeating.hideEditingPopup);

        window.onbeforeunload = app_repeating.warnLoseChanges;

        gemini_commons.inputKeyHandler($(document), null, app_repeating.hideEditingPopup);
        var api = $("#cs-popup-content", app_repeating.popupContainer).data('jsp');
  
        var th = $(elem).closest('table').find('th').eq($(elem).index());
        if ($("#" + $(th).data('id'), '#cs-popup-content').length != 0) {

            if (!$("*[name='" + $(th).data('id') + "'][type!='hidden']", '#cs-popup-content').is('select')) {
                api.scrollToY($("#" + $(th).data('id'), '#cs-popup-content').position().top);
                //$("#" + $(th).data('id'), '#cs-popup-content').focus().click();
                if ($("*[name='" + $(th).data('id') + "'][type!='hidden']", '#cs-popup-content').is(':checkbox')) {
                    $("#" + $(th).data('id'), '#cs-popup-content').focus();
                }
                else {
                    $("#" + $(th).data('id'), '#cs-popup-content').focus().click();
                }
            }
            else {
                api.scrollToY($('*[name="' + $(th).data('id') + '"] + div', '#cs-popup-content').position().top);
                $('*[name="' + $(th).data('id') + '"] + div', '#cs-popup-content').focus().mousedown();
            }

            $("#" + $(th).data('id'), '#cs-popup-content').parent().addClass("highlight-underline");
            $("#" + $(th).data('id'), '#cs-popup-content').parent().siblings().addClass("highlight-underline");
        }
        else {
            $("#cs-popup input[type='text']:first").focus();
        }
        var tr = $(elem).closest('tr');
        if ($(tr).hasClass('dependant') || $(tr).find('.parent').length == 1) {
            $('.dependant', '#tabledata').remove();
            $('.parent', '#tabledata').removeClass('fonticon-arrow-up').addClass('fonticon-arrow-down');
        }        

        gemini_keyboard.bindEscape("#cs-popup #cs-popup-close");
        gemini_ui.fancyInputs('#inline-edit-form .fancy');
        /*if (gemini_edit.editItemRenderedCallback) {
            gemini_edit.editItemRenderedCallback();
            gemini_edit.editItemRenderedCallback = null;
        }*/
    },
    setPendingChanges: function () {
        app_repeating.pendingChanges = true;
        $('#cs-popup-content').data('jsp').reinitialise({});
    },
    warnLoseChanges: function () {
        if (app_repeating.pendingChanges) {
            return "Unsaved changes.";
        }
    },
    saveEditing: function () {
        $('#server-validation-error', '#cs-popup').hide();

        if ($("#inline-edit-form", app_repeating.formContainer).valid()) {
            gemini_ui.startBusy('#cs-popup #cs-popup-save');
            $('#inline-edit-form', app_repeating.formContainer).submit();
            //gemini_ajax.postCall(csVars.ProjectUrl + "save", gemini_edit.pageType, gemini_edit.refresh, null, $('#inline-edit-form', gemini_edit.formContainer).serialize(), gemini_edit.issueId);
        }
        else {
            $('.error:not(label)', '#cs-popup-content').first().focus();
        }
    },
    hideEditingPopup: function () {
        $('#server-validation-error', '#cs-popup').hide();
        //gemini_edit.includeProjectsField = false;
        // wants to move away from editing?
        if (app_repeating.pendingChanges) {
            // warn of lost changes
            //$(gemini_edit.popupContainer).hide();
            //gemini_popup.sameConfirmWidth();
            gemini_popup.modalConfirm("Save changes?", null,
            function () {
                app_repeating.saveEditing();
            },
            function () {
                app_repeating.pendingChanges = false;
                app_repeating.hideEditingPopup();
            });
        }
        else {
            gemini_ui.destroyHtmlEditor("#cs-popup-content .wysiwyg-editor");
            // nothing to save, so dismiss
            $(app_repeating.popupContainer).hide();
            app_repeating.pendingChanges = false;
            //gemini_edit.editingMode = false;
            gemini_commons.inputKeyHandlerUnbind($(document));
            $('#cs-popup-content', app_repeating.popupContainer).empty();
            $('#cs-popup-content', app_repeating.popupContainer).data("jsp", "");

            gemini_keyboard.unbindEscape("#cs-popup #cs-popup-close");
            gemini_ui.stopBusy('#cs-popup #cs-popup-save');
            app_repeating.resetButtons();
            $.colorbox.close();
        }
    },
    resetButtons: function () {
        var orig = $('#cs-popup-save', '#cs-popup').attr('data-orig-val');
        if (orig && orig.length) {
            $('#cs-popup-save', '#cs-popup').val(orig);
            $('#cs-popup-save', '#cs-popup').attr('data-orig-val', '');
        }
    },
    refreshItemGrid: function ()
    {
        gemini_ajax.postCall("apps/Repeater", "getitemgrid", function (response) {
            $('#items-grid').replaceWith(response.Result.Data.Html);
           
            gemini_appnav.pageCard.Options['9B7E7603-5355-4324-AB63-BB37ED6786A0'] = gemini_commons.htmlEncode(JSON.stringify(gemini_appnav.pageCard.Filter));;

            $('#app-repeating .edit').click(function (e) {
                e.preventDefault();
                app_repeating.itemId = $(this).closest('tr').data('issue-id');

                gemini_ajax.postCall('item', "edit?viewtype=0", app_repeating.showEditingPopup, null, { id: app_repeating.itemId }, setTimeout(function () { $("#Repeat_Interval").focus(); }, 200));
            });

            $('#app-repeating .schedule').click(function (e) {
                e.preventDefault();
                app_repeating.itemId = $(this).closest('tr').data('issue-id');

                $("#cs-popup-center-content").css("width", "380px");
                $("#cs-popup-center-content").css("height", "150px");
                gemini_popup.centerPopup("apps/Repeater", "popup?itemId=" + app_repeating.itemId, null, null, "Generate");
            });

            $('#tabledata').on('click', '.expander', function (e) {
                gemini_commons.stopClick(e);
                var id = $(this).closest('tr').data('issue-id');

                if ($(this).hasClass('fonticon-arrow-down')) {
                    $('#app-repeating .repeat-of-' + id).show();
                    $(this).removeClass('fonticon-arrow-down');
                    $(this).addClass('fonticon-arrow-up');
                }
                else {
                    $('#app-repeating .repeat-of-' + id).hide();

                    $(this).removeClass('fonticon-arrow-up');
                    $(this).addClass('fonticon-arrow-down');
                }
            });

        }, null, null, null, true);
    },    
    datePicker: function (selector, onChange, onHide) {

        if (onHide == null || onHide == undefined) {
            onHide = function () { return true; };
        }
        $(selector).each(function () {

            var format = $(this).data('date-format');
            if (format == undefined) format = 'm/d/Y';
            var value = $(this).prop('value');
            if (value == undefined) value = '';
            var elem = this;

            $(elem).DatePicker({
                format: format,
                setDate: new Date(),
                date: value,
                current: value,
                starts: csVars.FirstDayOfWeek,
                flat: false,
                position: 'right',
                onBeforeShow: function () {
                    var value = $(this).prop('value');
                    if (value == undefined) value = '';
                    $(elem).DatePickerSetDate(value, true);
                    $('.datepicker').addClass('z-index-max');
                },
                onChange: function (formated, dates) {
                    $(elem).val(formated);
                    $(elem).DatePickerHide();
                    if (onChange)
                        onChange(formated, elem);
                },
                onHide: onHide
            });

        });
    },
    resizeMainItemsGrid: function () {
        var totalWidth = $('#page-content-zone .layout').width();
        /*var filterWidth = 0;

        if ($('#page-content-zone .filter-container').is(':visible'))
            filterWidth = $('#page-content-zone .filter-container').width() + 10;

        var contentWidth = totalWidth - filterWidth;*/
        var contentWidth = totalWidth;
        $('#page-content-zone .items-data-container').css('width', contentWidth + 'px');

        if ($('#tabledata', '#data').length != 0)
        {
            if ($('#tabledata', '#data').position().left + $('#tabledata', '#data').width() >= $('#side-pane').position().left)
            {
                $('#tabledata', '#data').css('padding-right', ($('#side-pane').width() + 20) + 'px');
            }
            else
            {
                $('#tabledata', '#data').css('padding-right', '');
            }
        }
        
    }
}