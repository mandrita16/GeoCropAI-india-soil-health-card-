/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  apis = ["iam.googleapis.com", "compute.googleapis.com", "container.googleapis.com", "spanner.googleapis.com"]
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_service" "project" {
  for_each = toset(local.apis)
  project  = data.google_project.project.project_id
  service  = each.key

  disable_on_destroy = false
}

resource "google_service_account" "scraper" {
  account_id = "anthrokrishi-scraper"
}

resource "google_storage_bucket" "shc-bucket" {
  name          = "anthrokrishi-shcs"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_project_iam_member" "logWriterCloudRun" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.scraper.email}"
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.shc-bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.scraper.email}"
}