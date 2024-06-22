gemini_changelog =
{
    executionUrl: '',

    currentVersionId: 0,

    currentProjectId: 0,

    init: function (versionId)
    {
        gemini_changelog.currentVersionId = versionId;

        gemini_changelog.currentProjectId = $('.changelog #Projects1').val();

        gemini_filter.gridReorderCallback = function (fromColumn, toColumn)
        {
            gemini_ajax.postCall("apps/changelog", "reordercolumns", function (response)
            {
                if (response.success)
                {
                    gemini_changelog.refreshchangelog(response.Result.Data);
                }

                gemini_ui.stopBusy('#modal-confirm #modal-button-yes');

            }, function (error) { gemini_ui.stopBusy('#modal-confirm #modal-button-yes'); }, { versionId: gemini_changelog.currentVersionId, projectId: gemini_changelog.currentProjectId, from: fromColumn, to: toColumn });
        }

        gemini_items.gridDeleteIssueRowCallback = function ()
        {
            gemini_changelog.refreshchangelog();
        };

        $('.changelog .data-inner-container').on('click', '.version-box', function (e)
        {
            e.preventDefault();

            $('.changelog #versions li').removeClass('selected');
            $(this).closest('li').addClass('selected');
         
            gemini_changelog.currentVersionId = $(this).attr('data-id');
            gemini_filter.executeEndPoint = gemini_changelog.executionUrl + gemini_changelog.currentVersionId + '&projectId=' + gemini_changelog.currentProjectId;
            
            gemini_changelog.refreshchangelog();
        });

        $('.changelog #Projects1').change(function ()
        {
            gemini_changelog.currentProjectId = $(this).val();
            gemini_filter.executeEndPoint = gemini_changelog.executionUrl + gemini_changelog.currentVersionId + '&projectId=' + gemini_changelog.currentProjectId;
            gemini_changelog.refreshchangelog();
        });

        $('#changelog-column-picker').click(function ()
        {
            if ($("#column-picker").is(":visible"))
            {
                $("#column-picker").fadeOut('fast');
                gemini_keyboard.unbindEscape("#column-picker");
            }
            else
            {
                gemini_ajax.call('apps/changelog', 'getcolumns?viewtype=' + gemini_filter.pageType + '&projectId=' + gemini_changelog.currentProjectId,
                    function (response)
                    {
                        if (response.Success)
                        {
                            $("#column-picker").css({
                                top: $("#changelog-column-picker").position().top + $("#changelog-column-picker").height() + 8,
                                left: $("#changelog-column-picker").position().left - 225
                            });

                            $('#column-picker').html(response.Result.Data);
                            $("#column-picker").slideDown('fast');

                            $('#colmun-picker-submit').click(function () {
                                $("#column-picker").fadeOut('fast');
                                gemini_ui.startBusy('#column-picker #colmun-picker-submit');

                                gemini_ajax.postCall('apps/changelog', 'setcolumns?projectId=' + gemini_changelog.currentProjectId + '&versionId=' + gemini_changelog.currentVersionId,
                                    function (response) {
                                        if (response.Success) {
                                            gemini_changelog.refreshchangelog(response.Result.Data.view);
                                        }
                                        gemini_ui.stopBusy('#column-picker #colmun-picker-submit');
                                    },
                                    function (xhr, ajaxOptions, thrownError) {
                                        gemini_ui.stopBusy('#column-picker #colmun-picker-submit');
                                    }, $('#column-picker-form').serialize());
                            });

                            gemini_keyboard.bindEscape("#column-picker", gemini_filter.EscapeDropdowns);

                            gemini_ui.fancyInputs('#column-picker .fancy');
                        }
                    });
            }
        });
    },

    initInlineEditing: function ()
    {
        $('#contents').on('click', '#tabledata tr:not(.drop-zone) td:not(:first-child):not(.read-only):not(.edit-mode)', function (e)
        {         
            //Making sure the edit doesn't get invoked when clicking on link
            if (!$(e.target).is('a'))
            {
                gemini_edit.initEditing($(this), true);
            }
        });
    },

    minutes: function (days, hours, mins)
    {
        return ((days * 8) + hours) * 60 + mins;
    },

    deltaString: function (min)
    {
        mins = Math.abs(min);
        hours = (mins >= 60) ? Math.floor(mins / 60) : 0;
        mins -= (hours * 60);
  
        // populate the screen
        $('.days-remaining').text(gemini_changelog.addLeadingZero(hours, 2) + 'h' + ' ' + gemini_changelog.addLeadingZero(mins, 2) + 'm');
 
    },

    showDelta: function (remain)
    {
        delta = remain;

        if (delta > 0)
        {
            $('.delta').removeClass("behind ahead").addClass("ahead");
        }
        else
        {
            $('.delta').removeClass("behind ahead").addClass("behind");
        }

        gemini_changelog.deltaString(delta);
    },

    showDays: function (Estimated, Logged, TimeOverLogged)
    {
        $('.days-est').text(gemini_changelog.addLeadingZero(Math.floor(Estimated / 60), 2) + 'h ' + gemini_changelog.addLeadingZero(Math.floor(Estimated % 60), 2) + 'm');
        $('.days-cpt').text(gemini_changelog.addLeadingZero(Math.floor(Logged / 60), 2) + 'h ' + gemini_changelog.addLeadingZero(Math.floor(Logged % 60), 2) + 'm');
        $('.days-excess').text(gemini_changelog.addLeadingZero(Math.floor(TimeOverLogged / 60), 2) + 'h ' + gemini_changelog.addLeadingZero(Math.floor(TimeOverLogged % 60), 2) + 'm');
    },

    addLeadingZero: function (num, size)
    {
        var s = num + "";
        while (s.length < size) s = "0" + s;
        return s;
    },

    showCompleteness: function (completeness, id)
    {
        var elem = '#statusbar .tinyProgress';
        if (id) elem = id;
        gemini_ui.tinyPercent(elem, Math.floor(completeness), '#0B0', '#4c4c4c', 500, 0, 0, 50);
    },

    showGrid: function (ProjectTemplatePageType, versionId, executeEndPoint)
    {
        gemini_changelog.executionUrl = executeEndPoint;
        gemini_changelog.currentVersionId = versionId;
        gemini_changelog.currentProjectId = $('.changelog #Projects1').val();
        gemini_filter.executeEndPoint = executeEndPoint + versionId + '&projectId=' + gemini_changelog.currentProjectId;

        gemini_filter.executeData = function ()
        {
            return $('#Sort').val();
        };

        gemini_filter.refreshTable = function (result)
        {
            gemini_changelog.refreshPage(result);     

            $('#items-grid').css('opacity', '1');
        };

        gemini_filter.init(ProjectTemplatePageType);

        gemini_edit.initEdit(0, ProjectTemplatePageType, '#cs-popup', '#cs-popup-content', '#data', gemini_changelog.refreshRow);
    },

    refreshPage: function (response)
    {
        if (response.grid)
        {
            $('#progress-items-table').html(response.grid);
        }

        if (response.statusBar) $('#statusbar').replaceWith(response.statusBar);
        if (response.versions) $('#versions').replaceWith(response.versions);
        
        gemini_changelog.showDelta(parseInt($('.changelog #statusbar #data-remain').val()));
        gemini_changelog.showDays(parseInt($('.changelog #statusbar #data-estimated').val()), parseInt($('.changelog #statusbar #data-logged').val()), parseInt($('.changelog #statusbar #data-time-logged-over').val()));
    },

    refreshchangelog: function (response)
    {
        var card = $.parseJSON(gemini_commons.htmlDecode(gemini_appnav.pageCard.Options['20A79C86-9FB4-4160-A4FD-29E37E185673']));

        card.PageData = { projectId: parseInt(gemini_changelog.currentProjectId), versionId: parseInt(gemini_changelog.currentVersionId) };

        if (response)
        {            
            card.DisplayColumns = response;            
        }

        gemini_appnav.pageCard.Options['20A79C86-9FB4-4160-A4FD-29E37E185673'] = gemini_commons.htmlEncode(JSON.stringify(card));

        gemini_ui.stopBusy('#modal-confirm #modal-button-yes');
        gemini_ajax.call("apps/changelog", "getchangelog", function (response)
        {
            if (response.Result.Data.success)
            {
                gemini_changelog.refreshPage(response.Result.Data);
                gemini_filter.initDataTable();
            }
            gemini_ui.stopBusy('#modal-confirm #modal-button-yes');
        }, function (error) { gemini_ui.stopBusy('#modal-confirm #modal-button-yes'); }, { versionId: gemini_changelog.currentVersionId, projectId: gemini_changelog.currentProjectId });
    },

    refreshRow: function (response, issueId)
    {
        gemini_ajax.call("apps/changelog", "getissuerow", function (response)
        {
            if (response.success)
            {
                $('#tr-issue-' + issueId, '#tabledata').replaceWith(response.Result.Html);
                gemini_items.bindContextMenu();
                gemini_filter.initTableDnD()
            }
        }, null, { issueId: issueId });
    }
};