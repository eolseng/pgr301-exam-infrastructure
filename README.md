## Opprettelse av infrastruktur
1. Opprett et GCP prosjekt
2. Lag en `Cloud Storage Bucket` for å oppbevaring av Terraform State - navn kan være `[PROSJEKTNAVN]-terraform-state`
    * Aktiver versjonering ved å kjøre følgende kommando i en terminal med rettigheter til prosjektet, som `Cloud Shell` i nettleseren
    ```
    gsutil versioning set on gs://[BUCKET NAVN]
    ```
3. Lag en `Service Account` for Terraform
    * Gi rollene beskrevet senere i dokumentet
    * Eksporter en .json-nøkkel for Service Accounten
    * Navngi nøkkelen som `gcp_keyfile.json` og legg den i `./keyfiles`-mappen
4. Opprett en `terraform.tfvars`-fil i rot-mappen med følgende konfigurering:
    ```
    project_name = [Prosjektnavnet]
    project_region = [Prosjektregionen]
    ```
5. Opprett eller rediger `backend.tf`-filen i rot mappen med følgende innhold:
    ```
   terraform {
     backend "gcs" {
       credentials = "./keyfiles/gcp_keyfile.json"
       bucket = "[Navnet på bucketen opprettet i steg 2]"
     }
   }
   ```
6. Krypter `gcp_keyfile.json` og `terraform.tfvars` på Travis-CI med følgende kommando:
    ```
    travis --pro encrypt-file terraform.tfvars --add && \
    travis --pro encrypt-file ./keyfiles/gcp_keyfile.json --add
    ```
   * NB.: Krever pålogget bruker på Travis-CI sin CLI
7. Kjør kommandoen `terraform init`

## Service Account Roles
* Service Account User - gir Terraform tilgang til å utføre operasjoner som andre Service Accounts
* Storage Admin - gir Terraform tilgang til Cloud Storage