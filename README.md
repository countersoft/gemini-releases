# Countersoft Gemini

Latest Gemini release is v7.4.0 -- download ZIP release or clone this repo.

Requirements:

- .NET Framework 4.7.2 or above
- SQL Server (any edition/version but preferably 2012 or above)

## Self-host

Download ZIP file from latest release.

Follow [install video](https://vimeo.com/87858540).

## Azure

For deployment to Azure follow the [instructions](Azure.md). 

**Please note you will need to edit the deployment YAML file in GitHub Actions to put in your publish profile GUID.**

Example: publish-profile: ${{ secrets.AZUREAPPSERVICE_PUBLISHPROFILE_<your GUID>}}

## Licensing

See [EULA.pdf](EULA.pdf) for licensing.

## Support

Contact support@countersoft.com for installation help.
