> Eksamen | PGR301 - DevOps i skyen | Kandidatnummer: 10004
# Terraform Infrastructure [![Build Status](https://travis-ci.com/eolseng/pgr301-exam-infrastructure.svg?branch=master)](https://travis-ci.com/eolseng/pgr301-exam-infrastructure)

Dette repositoriet er infrastruktur-biten av eksamenen min i faget **PGR301 - DevOps i skyen**.
Prosjektet viser hvordan man kan bruke **Travis-CI** og **Terraform** til å kontrollere infrastruktur, med hovedvekt på **Google Cloud Platform** som Terraform provider.

###### Oppsett
Under _"Opprettelse av infrastruktur"_ går jeg igjennom stegene for å konfigurere de forskjellige tjenestene slik at Terraform kan kontrollere mest mulig.

###### Samlet Terraform kode
All Terraform-kode er samlet i `/tf` mappen for bedre oversikt.
Dersom man skal utføre Terraform-operasjoner lokalt må man derfor suffixe kommandoer med 'tf', som `terraform plan tf` eller `terraform apply tf`.

## Todo
- [ ] Undersøke om jeg trenger `terraform output` etter `terraform apply`. `terraform output tf` fungerer ikke, så må evt. gjøre endringer i logikken.

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

6. Krypter `gcp_keyfile.json` og variabler for prosjektnavn og region for bruk på Travis-CI med følgende kommandoer:
    ```
    travis encrypt-file --pro gcp_keyfile.json --add
    travis encrypt --pro PROJECT_NAME="[Prosjektnavnet]" --add
    travis encrypt --pro PROJECT_REGION="[Prosjektregionen]" --add
    ```
    NB.: Krever pålogget bruker på Travis-CI sin CLI

7. Prosjektet er nå konfigurert slik at et push til `master` branchen vil oppdatere infrastrukturen i henhold til filene i dette prosjektet.

## Terraform Service Account Roles
* `Storage Admin` - gir Terraform tilgang til Cloud Storage for å skrive til State Bucketen.
* `Service Usage Admin` - lar Terraform kontrollere hvilke services som er aktive via "google_project_service" resourcen
* `Service Account User` - lar Terraform utføre operasjoner som andre Service Accounts
* `Cloud Run Admin` - lar Terraform ha full tilgang til Cloud Run ressurser

## Annet
* `terraform apply` utføres kun ved push til `master` branc. Det er derfor mulig å branche ut og se resultatet av `terraform plan` før endringer går i produksjon.
