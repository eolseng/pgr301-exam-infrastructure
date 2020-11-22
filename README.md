> Eksamen | PGR301 - DevOps i skyen | Kandidatnummer: 10004
# Terraform Infrastructure [![Build Status](https://travis-ci.com/eolseng/pgr301-exam-infrastructure.svg?branch=master)](https://travis-ci.com/eolseng/pgr301-exam-infrastructure)

Dette repositoriet er infrastruktur-biten av eksamenen min i faget **PGR301 - DevOps i skyen**.
Prosjektet viser hvordan man kan bruke **Travis-CI** og **Terraform** til å kontrollere infrastruktur, med hovedvekt på **Google Cloud Platform** som Terraform provider.

## Benyttede resources
* `google_project_service` - aktiverer nødvendige tjenester i Google Cloud prosjektet.
* `google_container_registry` - image registry som [det andre repositoriet til eksamenen](https://github.com/eolseng/pgr301-exam-auth) pusher sine images til. 
* `google_cloud_run_service` - kjører applikasjonen som ligger i Container Registryet.
    * `google_iam_policy` og `google_cloud_run_service_iam_policy` tillater offentlig tilgang til tjenesten
* `google_sql_database_instance` - hoster en PostgreSQL database for applikasjonen
    * `google_sql_database` - oppretter en database
    * `google_sql_user` - oppretter en database-bruker for applikasjonen
* `statuscake_test` - brukes til å teste om applikasjonen er oppe ved å sende enkle HTTP-meldinger
* `random_password` - brukes til å generere passord til brukere
### Ekstra providere - InfluxDB og Grafana i `feature/metrics` branchen
I `feature/metrics` branchen har jeg konfigurert InfluxDB og Grafana for bruk med applikasjonen.
Jeg fant dessverre ingen god måte å hoste dette på via Terraform eller en annen provider da [InfluxData](https://www.influxdata.com/) nå bruker versjon 2 og SpringBoot sin Micrometer ikke har støtte for dette enda.

Ved å starte den vedlagte Docker Compose filen med `docker-compose -f metrics-compose.yml up` og sette Terraform Variablene under kan man utføre en `terraform plan tf` for å bekrefte at det vil fungere.
* `influxdb_database` - oppretter en database i InfluxDB for applikasjonen
* `influxdb_user` - oppretter en bruker for applikasjonen å skrive data til InfluxDB og en bruker for Grafana til å lese data fra InfluxDB
* `grafana_data_source` - oppretter en Data Source i Grafana for InfluxDBen som er konfigurert
* `grafana_dashboard` - laster inn et ferdiglaget dashboard for applikasjonen
Dersom man har InfluxDB(<v.2) og Grafana hostet kan man kopiere over InfluxDB konfigurasjonen fra `application-dev.yml` til `application-prod.yml` så skal det fungere.  

###### Samlet Terraform kode
All Terraform-kode er samlet i `/tf` mappen for bedre oversikt.
Dersom man skal utføre Terraform-operasjoner lokalt må man derfor suffixe kommandoer med 'tf', som `terraform plan tf` eller `terraform apply tf`.

## Opprettelse av infrastruktur
1. Opprett et Google Cloud Platform prosjekt
2. Lag en `Cloud Storage Bucket` for å oppbevaring av Terraform State - navn kan være `[PROSJEKTNAVN]-terraform-state`
    * Aktiver versjonering ved å kjøre følgende kommando i en terminal med rettigheter til prosjektet, som `Cloud Shell` direkte i Google Cloud Platform prosjektet
    ```
    gsutil versioning set on gs://[BUCKETNAVN]
    ```
3. Aktiver nødvendige GCP APIer via en terminal med rettigheter:
    ```
   // Lar Terraform kontrollere hvilke servicer som er aktive via "google_project_service" resourcen
    gcloud services enable cloudresourcemanager.googleapis.com
    ```
4. Lag en `Service Account` for Terraform
    * Gi kontoen de rollene som er beskrevet i _"Terraform Service Account Roles"_
    * Eksporter en .json-nøkkel for kontoen
    * Navngi nøkkelen som `gcp_keyfile.json` og plasser den i prosjektetes rot-mappe
    
5. Opprett eller rediger `backend.tf`-filen i rot mappen med følgende innhold:
    ```
   terraform {
     backend "gcs" {
       credentials = "gcp_keyfile.json"
       bucket = "[Navnet på bucketen opprettet i steg 2]"
     }
   }
   ```
6. Sett variablene for `TF_VAR_auth_app_image` og `TF_VAR_auth_app_tag` i `.travis.yml` filen.

7. Krypter `gcp_keyfile.json` og variabler for prosjektnavn og region for bruk på Travis-CI med følgende kommandoer:
    ```
   // Google Cloud Platform
   travis encrypt-file --pro gcp_keyfile.json --add
   travis encrypt --pro PROJECT_NAME="[Prosjektnavnet]" --add
   travis encrypt --pro PROJECT_REGION="[Prosjektregionen]" --add
   // Logz.io
   travis encrypt --pro TF_VAR_logzio_token=[Token for Logz.io-bruker] --add
   travis encrypt --pro TF_VAR_logzio_url=[Listener URL for Logz.io] --add
   // Statuscake
   travis encrypt --pro TF_VAR_statuscake_username=[Statuscake Username] --add
   travis encrypt --pro TF_VAR_statuscake_apikey=[Statuscake API-key] --add
   travis encrypt --pro TF_VAR_statuscake_contact_group=[Statuscake Contact Group IDs to be notified if service goes down (list of strings)] --add
    ```
    NB.: Krever pålogget bruker på Travis-CI sin CLI

8. Prosjektet er nå konfigurert slik at et push til `master` branchen vil oppdatere infrastrukturen i henhold til filene i dette prosjektet.

## Terraform Service Account Roles
* `Storage Admin` - gir Terraform tilgang til Cloud Storage for å skrive til State Bucketen.
* `Service Usage Admin` - lar Terraform kontrollere hvilke services som er aktive via "google_project_service" resourcen
* `Service Account User` - lar Terraform utføre operasjoner som andre Service Accounts
* `Cloud Run Admin` - lar Terraform ha full tilgang til Cloud Run ressurser
* `Cloud SQL Admin` - lar Terraform ha full tilgang til Cloud SQL ressurser

## Annet
* `terraform apply` utføres kun ved push til `master` branch. Det er derfor mulig å branche ut og se resultatet av `terraform plan` før endringer går i produksjon.
