# How to Update or Reset TelePulse Channels

The channel list is sourced directly from the global `iptv-org` community database. Because live streaming links frequently die or change, you should periodically update your Supabase database to grab the freshest links.

Follow these two steps to perform a clean update:

### Step 1: Wipe the Old Channels
To prevent duplicate channels from piling up, you must completely empty your database table before pulling new data.

1. Open your [Supabase Dashboard](https://supabase.com/dashboard).
2. Go to the **SQL Editor** on the left menu.
3. Open a "New Query" and run the following command:
   ```sql
   TRUNCATE TABLE channels;
   ```
   *(This instantly deletes all 11,000+ rows from your database).*

### Step 2: Run the Seeder Script
Now that your database is clean, you can run the automated seeder script. This script will download the latest `index.category.m3u` and `index.language.m3u` playlists from GitHub, smartly merge their metadata, and upload them in batches to your Supabase.

1. Open your terminal in the root folder of this project (`Watchai`).
2. Run the following command:
   ```bash
    dart run scripts/seed_data.dart
   ```
3. The terminal will show the progress. It usually takes about 1-2 minutes to insert all batches.

### Step 3: Hot Restart
Once the script finishes uploading, simply restart your app (press `R` in your Flutter terminal) to sync the fresh data to your UI!
