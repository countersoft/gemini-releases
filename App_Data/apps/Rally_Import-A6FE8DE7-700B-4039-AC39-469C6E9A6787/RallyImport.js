app_rallyImport = {
    
    interval:null,

    initCredentials: function() 
    {
        app_rallyImport.stopInterval();
        $('#rally-connect').click(function()
        {
            if ($("#rally-credentials-form").valid()) {
            
                gemini_ui.startBusy('#cs-adhoc-page .data-entry-box #rally-connect');

                gemini_ajax.postCall("apps/RallyImport", "connect",
                function (response) {
                    if (response.success)
                    {
                        $('.rally-credentials').before(response.Result.Data.Html);
                        $('.rally-credentials').remove();                        
                    }
                    else
                    {
                        gemini_popup.toast(response.Message, true);
                    }

                    gemini_ui.stopBusy('#cs-adhoc-page .data-entry-box #rally-connect');
                }, function () { gemini_ui.stopBusy('#cs-adhoc-page .data-entry-box #rally-connect'); }, $('#rally-credentials-form').serialize(), null, true);
            }
        });
    },

    initMappings: function() 
    {
        app_rallyImport.stopInterval();
        gemini_ui.chosen('#rally-mappings-form select', null);

        $('#rally-map-import').click(function()
        {
            if ($("#rally-mappings-form").valid()) {
            
                gemini_ui.startBusy('#cs-adhoc-page .data-entry-box #rally-map-import');

                gemini_ajax.postCall("apps/RallyImport", "import",
                function (response)
                {
                    if (response.success)
                    {
                        $('.rally-projects').before(response.Result.Data.Html);
                        $('.rally-projects').remove();                        
                    }
                    else
                    {
                        gemini_popup.toast(response.Message, true);
                    }

                    gemini_ui.stopBusy('#cs-adhoc-page .data-entry-box #rally-map-import');
                }, function () { gemini_ui.stopBusy('#cs-adhoc-page .data-entry-box #rally-map-import'); }, $('#rally-mappings-form').serialize(), null, true);
            }
        });
    },

    initStatus: function() 
    {
        if(app_rallyImport.interval == null)
        {
            app_rallyImport.interval = setTimeout(function()
            {
                gemini_ajax.postCall("apps/RallyImport", "status",
                    function (response) 
                    {
                        if (response.success)
                        {
                            $('.rally-status').replaceWith(response.Result.Data.Html);
                        }
                        else
                        {
                            gemini_popup.toast(response.Message, true);
                        }

                    }, null, {check:1}, null, true);
            }, 10000);
        }
    },

    stopInterval: function()
    {
        if(app_rallyImport.interval)
        {
            clearTimeout(app_rallyImport.interval);
            app_rallyImport.interval = null;
        }
    }
};