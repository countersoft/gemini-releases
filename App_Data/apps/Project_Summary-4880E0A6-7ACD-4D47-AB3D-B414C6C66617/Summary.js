App_Summary = {
    currentListValues: null,
    init: function()
    {
        App_Summary.reportChanged();
        
        $(".report-summary-table-button", "#report-menu").click(function () {
            $("#SummaryChart").val("false");
            $(".report-summary-chart").fadeOut('fast', function () {
                $(".report-summary-table").fadeIn('fast');
            });
            var options = JSON.parse(gemini_appnav.pageCard.Options['4880E0A6-7ACD-4D47-AB3D-B414C6C66617']);
            options.SummaryChart = false;

            gemini_appnav.pageCard.Options['4880E0A6-7ACD-4D47-AB3D-B414C6C66617'] = JSON.stringify(options);
        });
        $(".report-summary-chart-button", "#report-menu").click(function () {
            $("#SummaryChart").val("true");
            $(".report-summary-table").fadeOut('fast', function () {
                $(".report-summary-chart").fadeIn('fast');
            });

            var options = JSON.parse(gemini_appnav.pageCard.Options['4880E0A6-7ACD-4D47-AB3D-B414C6C66617']);
            options.SummaryChart = true;

            gemini_appnav.pageCard.Options['4880E0A6-7ACD-4D47-AB3D-B414C6C66617'] = JSON.stringify(options);
        });

        $('.control-icon', '#report-menu').click(function () {
            var _this = $(this);
            var options = _this.find('+ .options');

            if (options.is(":visible")) {
                options.hide();
                gemini_keyboard.unbindEscape("#page-options-box .options");
            }
            else {
                _this.parent().parent().find(".options").each(function () {
                    if ($(this).is(":visible")) {
                        $(this).hide();
                    }
                });

                options.show();
                gemini_keyboard.bindEscape("#page-options-box .options", App_Summary.escapeDropdowns);
                $("input[type='text']:first", options).focus();
            }

            options.position({
                "of": _this,
                "my": "right top",
                "at": "right bottom",
                "offset": "0 0",
                "collision": "none"
            });
        });

        App_Summary.currentListValues = $('#ProjectIds').val();

        $("#ProjectIds").change(function (e) {
            App_Summary.projectChanged();
            App_Summary.reportChanged();            
        });
    },
    escapeDropdowns: function (guid, selector) {
        $(selector).hide();
        gemini_keyboard.unbindEscape(guid);
    },
    projectAttributeChanged: function() {
        var value = $('#ProjectIds').val();

        var successCallback = function (response)
        {
            if (response.success)
            {
                $('#ProjectAttributeContainer').html(response.Result.Data.Html);
            }
        }

        gemini_ajax.postCall("apps/Summary", "getProjectAttributes", successCallback, null, { projectIds: value }, null, true);
    },
    projectChanged: function () {
        var value = $('#ProjectIds').val();

        var any = $('option:first', $('#ProjectIds')).val();

        if (value != null && value != undefined && value.length > 1 && value.indexOf(any) != -1)
        {
            if (App_Summary.currentListValues != null && App_Summary.currentListValues != undefined && App_Summary.currentListValues.indexOf(any) != -1)
            {
                var newSelected = $('#ProjectIds').val();
                newSelected.splice(0, 1);
                $('#ProjectIds').val(newSelected);
            }
            else
            {
                $('#ProjectIds').val(any);
            }
        }
        else if (value == null || value == undefined)
        {
            $('#ProjectIds').val(any);
        }

        gemini_ui.chosenUpdate($('#ProjectIds'));

        App_Summary.currentListValues = $('#ProjectIds').val();
    },
    reportChanged: function () {
        gemini_ui.cursorWait();

        $("#report-content").html("<div id='cs-template'><div id='no-data'>Loading...</div></div>");

        var options = $("#ReportParams").serializeArray();

        var report = {};
        report['name'] = 'Reports'
        report['value'] = '31'

        options.push(report);

        var reportIndex = 0;

        for (index = 0; index < options.length; ++index) {
            if (options[index].name == "Reports") {
                reportIndex = index;
                break;
            }
        }

        options[reportIndex].value = 30;
        gemini_ajax.postCall("apps/Summary", "get", LoadSummary, null, jQuery.param(options), null, true);        

        function LoadSummary(response) {
            $("#report-content").html(response.Result.Html);
            
            if (response.Result.SavedCard != null) {
                gemini_appnav.pageCard.Options['4880E0A6-7ACD-4D47-AB3D-B414C6C66617'] = response.Result.SavedCard.Options['4880E0A6-7ACD-4D47-AB3D-B414C6C66617'];
            }

            options[reportIndex].value = 31;
            gemini_ajax.postCall("apps/Summary", "get", LoadComponents, null, jQuery.param(options), null, true);
            options[reportIndex].value = 32;
            gemini_ajax.postCall("apps/Summary", "get", LoadVersions, null, jQuery.param(options), null, true);
            options[reportIndex].value = 33;
            gemini_ajax.postCall("apps/Summary", "get", LoadResources, null, jQuery.param(options), null, true);
            options[reportIndex].value = 34;
            gemini_ajax.postCall("apps/Summary", "get", LoadTypes, null, jQuery.param(options), null, true);
            options[reportIndex].value = 35;
            gemini_ajax.postCall("apps/Summary", "get", LoadPriorities, null, jQuery.param(options), null, true);
            options[reportIndex].value = 36;
            gemini_ajax.postCall("apps/Summary", "get", LoadSeverities, null, jQuery.param(options), null, true);
            options[reportIndex].value = 37;
            gemini_ajax.postCall("apps/Summary", "get", LoadStatuses, null, jQuery.param(options), null, true);
            options[reportIndex].value = 38;
            gemini_ajax.postCall("apps/Summary", "get", LoadResolutions, null, jQuery.param(options), null, true);

            App_Summary.projectAttributeChanged();

            gemini_ui.cursorDefault();
        }

        function LoadComponents(response) {
            $("#ComponentSummaryContainer").html(response.Result.Html);
        }
        function LoadVersions(response) {
            $("#VersionSummaryContainer").html(response.Result.Html);
        }
        function LoadResources(response) {
            $("#ResourceSummaryContainer").html(response.Result.Html);
        }
        function LoadTypes(response) {
            $("#TypeSummaryContainer").html(response.Result.Html);
        }
        function LoadPriorities(response) {
            $("#PrioritySummaryContainer").html(response.Result.Html);
        }
        function LoadSeverities(response) {
            $("#SeveritySummaryContainer").html(response.Result.Html);
        }
        function LoadStatuses(response) {
            $("#StatusSummaryContainer").html(response.Result.Html);
        }
        function LoadResolutions(response) {
            $("#ResolutionSummaryContainer").html(response.Result.Html);
        }
    }
}