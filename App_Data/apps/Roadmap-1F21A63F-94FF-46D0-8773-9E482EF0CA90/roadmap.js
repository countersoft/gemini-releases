gemini_roadmap =
{
    executionUrl: '',

    currentVersionId: 0,

    currentProjectId: 0,

    init: function (versionId)
    {
        gemini_roadmap.currentVersionId = versionId;
        gemini_roadmap.currentProjectId = $('.roadmap #Projects1').val();
        gemini_ui.fancyInputs('#includesub');
        $('.roadmap .data-inner-container').on('ifChanged', '#includesub', gemini_roadmap.includeSubversions);

        gemini_filter.gridReorderCallback = function (fromColumn, toColumn)
        {
            gemini_ajax.postCall("apps/roadmap", "reordercolumns", function (response)
            {
                if (response.success)
                {
                    gemini_roadmap.refreshRoadmap(response.Result.Data);
                }
                gemini_ui.stopBusy('#modal-confirm #modal-button-yes');
            }, function (error) { gemini_ui.stopBusy('#modal-confirm #modal-button-yes'); }, { versionId: gemini_roadmap.currentVersionId, projectId: gemini_roadmap.currentProjectId, from: fromColumn, to: toColumn });
        }

        gemini_items.gridDeleteIssueRowCallback = function ()
        {
            gemini_roadmap.refreshRoadmap();
        };

        $('.roadmap .data-inner-container').on('click', '.version-box', function (e)
        {
            e.preventDefault();

            $('.roadmap #versions li').removeClass('selected');
            $(this).closest('li').addClass('selected');
         
            gemini_roadmap.currentVersionId = $(this).attr('data-id');
            gemini_roadmap.execEndpoint();
                        
            gemini_roadmap.refreshRoadmap();
        });

        $('.roadmap #Projects1').change(function ()
        {
            gemini_roadmap.currentProjectId = $(this).val();
            gemini_roadmap.execEndpoint();
            gemini_roadmap.refreshRoadmap();
        });

        $('#roadmap-column-picker').click(function ()
        {
            if ($("#column-picker").is(":visible"))
            {
                $("#column-picker").fadeOut('fast');
                gemini_keyboard.unbindEscape("#column-picker");
            }
            else
            {
                gemini_ajax.call('apps/roadmap', 'getcolumns?viewtype=' + gemini_filter.pageType + '&projectId=' + gemini_roadmap.currentProjectId,
                    function (response)
                    {
                        if (response.Success)
                        {
                            $("#column-picker").css({
                                top: $("#roadmap-column-picker").position().top + $("#roadmap-column-picker").height() + 8,
                                left: $("#roadmap-column-picker").position().left - 225
                            });

                            $('#column-picker').html(response.Result.Data);
                            $("#column-picker").slideDown('fast');

                            $('#colmun-picker-submit').click(function ()
                            {
                                $("#column-picker").fadeOut('fast');
                                gemini_ui.startBusy('#column-picker #colmun-picker-submit');

                                gemini_ajax.postCall('apps/roadmap', 'setcolumns?projectId=' + gemini_roadmap.currentProjectId + '&versionId=' + gemini_roadmap.currentVersionId,
                                    function (response)
                                    {
                                        if (response.Success)
                                        {
                                            gemini_roadmap.refreshRoadmap(response.Result.Data.view);
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

    includeSubversions: function() {
        gemini_roadmap.execEndpoint(); 
        gemini_roadmap.refreshRoadmap();
    },

    execEndpoint: function() {
        gemini_filter.executeEndPoint = gemini_roadmap.executionUrl + gemini_roadmap.currentVersionId + '&projectId=' + gemini_roadmap.currentProjectId + "&includeSubVersions=" + $('#includesub').is(':checked');
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
        $('.days-remaining').text(gemini_roadmap.addLeadingZero(hours, 2) + 'h' + ' ' + gemini_roadmap.addLeadingZero(mins, 2) + 'm'); 
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

        gemini_roadmap.deltaString(delta);
    },

    showDays: function (Estimated, Logged, TimeOverLogged)
    {
        $('.days-est').text(gemini_roadmap.addLeadingZero(Math.floor(Estimated / 60), 2) + 'h ' + gemini_roadmap.addLeadingZero(Math.floor(Estimated % 60), 2) + 'm');
        $('.days-cpt').text(gemini_roadmap.addLeadingZero(Math.floor(Logged / 60), 2) + 'h ' + gemini_roadmap.addLeadingZero(Math.floor(Logged % 60), 2) + 'm');
        $('.days-excess').text(gemini_roadmap.addLeadingZero(Math.floor(TimeOverLogged / 60), 2) + 'h ' + gemini_roadmap.addLeadingZero(Math.floor(TimeOverLogged % 60), 2) + 'm');
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
        gemini_roadmap.executionUrl = executeEndPoint;

        gemini_roadmap.currentVersionId = versionId;
        gemini_roadmap.currentProjectId = $('.roadmap #Projects1').val();

        gemini_roadmap.execEndpoint();//  gemini_filter.executeEndPoint = executeEndPoint + versionId + '&projectId=' + gemini_roadmap.currentProjectId;

        gemini_filter.executeData = function ()
        {
            return $('#Sort').val();
        };
        gemini_filter.refreshTable = function (result)
        {
            gemini_roadmap.refreshPage(result);        

            $('#items-grid').css('opacity', '1');
        };
        gemini_filter.init(ProjectTemplatePageType);

        gemini_edit.initEdit(0, ProjectTemplatePageType, '#cs-popup', '#cs-popup-content', '#data', gemini_roadmap.refreshRow);
    },

    refreshPage: function (response)
    {
        if (response.grid)
        {
            $('#progress-items-table').html(response.grid);
        }

        if (response.statusBar) $('#statusbar').replaceWith(response.statusBar);
        if (response.versions) $('#versions').replaceWith(response.versions);
        
        gemini_roadmap.showDelta(parseInt($('.roadmap #statusbar #data-remain').val()));
        gemini_roadmap.showDays(parseInt($('.roadmap #statusbar #data-estimated').val()), parseInt($('.roadmap #statusbar #data-logged').val()), parseInt($('.roadmap #statusbar #data-time-logged-over').val()));
        gemini_ui.fancyInputs('#includesub');
    },

    refreshRoadmap: function (response)
    {
        var card = $.parseJSON(gemini_commons.htmlDecode(gemini_appnav.pageCard.Options['1F21A63F-94FF-46D0-8773-9E482EF0CA90']));

        card.PageData = { projectId: parseInt(gemini_roadmap.currentProjectId), versionId: parseInt(gemini_roadmap.currentVersionId), includeSubversions: $('#includesub').is(':checked') };

        if (response)
        {            
            card.DisplayColumns = response;            
        }

        gemini_appnav.pageCard.Options['1F21A63F-94FF-46D0-8773-9E482EF0CA90'] = gemini_commons.htmlEncode(JSON.stringify(card));

        gemini_ui.stopBusy('#modal-confirm #modal-button-yes');
        gemini_ajax.call("apps/roadmap", "getroadmap", function (response)
        {
            if (response.Result.Data.success)
            {
                gemini_roadmap.refreshPage(response.Result.Data);
                gemini_filter.initDataTable();
                gemini_ui.fancyInputs('#includesub');
            }
            gemini_ui.stopBusy('#modal-confirm #modal-button-yes');
        }, function (error) { gemini_ui.stopBusy('#modal-confirm #modal-button-yes'); }, { versionId: gemini_roadmap.currentVersionId, projectId: gemini_roadmap.currentProjectId, includeSubVersions: $('#includesub').is(':checked')});
    },

    refreshRow: function (response, issueId)
    {
        gemini_ajax.call("apps/roadmap", "getissuerow", function (response)
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