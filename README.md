## Opprettelse av infrastruktur
1. Opprett et GCP prosjekt
2. Lag en `Cloud Storage Bucket` for å oppbevaring av Terraform State - navn kan være `[PROSJEKTNAVN]-terraform-state`
    * Aktiver versjonering ved å kjøre følgende kommando i en terminal med rettigheter til prosjektet, som `Cloud Shell` i nettleseren
    ```
    gsutil versioning set on gs://[BUCKETNAVN]
    ```

3. Lag en `Service Account` for Terraform
    * Gi kontoen de rollene som er beskrevet senere i dokumentet
    * Eksporter en .json-nøkkel for kontoen
    * Navngi nøkkelen som `gcp_keyfile.json` og plasser den i prosjektetes rot-mappe
    
4. Opprett eller rediger `backend.tf`-filen i rot mappen med følgende innhold:
    ```
   terraform {
     backend "gcs" {
       credentials = "gcp_keyfile.json"
       bucket = "[Navnet på bucketen opprettet i steg 2]"
     }
   }
   ```

5. Krypter `gcp_keyfile.json` og variabler for prosjektnavn og region for bruk på Travis-CI med følgende kommandoer:
    ```
    travis encrypt-file --pro gcp_keyfile.json --add
    travis encrypt --pro PROJECT_NAME="[PROSJEKTNAVNET]" --add
    travis encrypt --pro PROJECT_REGION="[PROSJEKTREGION]" --add
    ```
    NB.: Krever pålogget bruker på Travis-CI sin CLI

6. Prosjektet er nå konfigurert slik at et push til `master` branchen vil oppdatere infrastrukturen i henhold til filene i dette prosjektet. 

## Service Account Roles
### Travis-CI + Terraform 
* Service Account User - gir Terraform tilgang til å utføre operasjoner som andre Service Accounts
* Storage Admin - gir Terraform tilgang til Cloud Storage