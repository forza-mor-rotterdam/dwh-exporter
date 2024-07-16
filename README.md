# DWH exporter

DWH exporter exporteert data uit PostgreSQL databases als CSV bestand naar een SSH/SFTP server (`scp` wordt hiervoor gebruikt) zodat deze kunnen worden geimporteerd in een datawarehouse platform.

## Hoe werkt het

DWH exporter is een Docker container die je uitvoert als een job. Je start de container met specifieke environment variabelen, als de export klaar is stopt de container en kun je deze weer verwijderen.

Je kan hiervoor bijvoorbeeld een k8s (Kubernetes) cronjob gebruiken.

## Environment variabels

| Variabel | Omschrijving |
|----------|--------------|
| DWH_KNOWN_HOSTS | De inhoud voor het `.ssh/known_hosts` bestand zodat de verbinding met de SSH server |
| DWH_SFTP_PRIVATE_KEY | De private key voor toegang tot de SSH server, in PEM formaat, zonder passphrase |
| DWH_USERNAME | De gebruikersnaam voor connectie met de SSH server |
| DWH_HOSTNAME | De hostname van de SSH server |
| DWH_LOCATION | De locatie op de SSH server waar de bestanden in geplaatst moeten worden |
| DWH_PREFIX | Prefix alle bestanden met deze waarde. CSV bestanden krijgen de naam `{prefix}{table}.csv` |
| TABLES | De tabellen/views die geexporteerd moeten worden, gescheiden met een spatie |
| PGHOST | Servername of the PostgreSQL server |
| PGPORT | Postgres port number |
| PGDATABASE | Postgres database name |
| PGUSER | Username to connect to Postgres |
| PGPASSWORD | Password to connect to Postgres |

Voor meer Postgres environement variabelen zie https://www.postgresql.org/docs/current/libpq-envars.html

## Inzet in K8S

    apiVersion: batch/v1
    kind: CronJob
    metadata:
        name: dwh-export
        namespace: my-cool-project-production
    spec:
        schedule: "0 5 * * *"
        concurrencyPolicy: Forbid
        successfulJobsHistoryLimit: 2
        failedJobsHistoryLimit: 2
        timeZone: "Europe/Amsterdam"
        jobTemplate:
            spec:
                template:
                    spec:
                        containers:
                            -   name: exporter
                                image: ghcr.io/forza-mor-rotterdam/dwh-exporter:main
                                imagePullPolicy: Always
                                envFrom:
                                    - secretRef:
                                        name: dwh-private-key
                                    - secretRef:
                                        name: postgresql-connection
                                env:
                                    -   name: TABLES
                                        value: feedback_feedback
                                    -   name: DWH_HOSTNAME
                                        value: transfer-server
                                    -   name: DWH_LOCATION
                                        value: /data/import/dwh
                                    -   name: DWH_PREFIX
                                        value: production-
                                    -   name: DWH_USERNAME
                                        value: export
                                    -   name: DWH_KNOWN_HOSTS
                                        value: "|1|73vxxageImi2k0nTTk0UZNyVMc8=|3koR+pgjEw4rCxBjjVTDg0/uZNI= ssh-ed25519 AAAAC3NzaC1lZDI1a255AAAAIDqHoZSvol7aqwtjskX/hObVqwaxaULdoaNp1jPP7MH"

