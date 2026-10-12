#!/usr/bin/env bash
set -e
mkdir -p runbooks incidents
cat > runbooks/db-failover.md <<'P'
# Database failover

1. The on-call engineer gets the page from the "primary-down" alert.
2. They check replication lag on the replica dashboard. If lag is over 30 seconds, stop and call the database lead.
3. They promote the replica with `dbctl promote replica-1`.
4. They switch the app's DATABASE_URL secret to the new primary and restart the API.
5. They post in #incidents and open a ticket to rebuild the old primary as a replica.
P
cat > incidents/2026-03-02-chat.md <<'P'
# #incidents, 2 March 2026

09:14 Priya: promoted replica-1 with 4 minutes of lag. We lost about 4 minutes of orders.
09:40 Sam: from now on, never promote above 30 seconds of lag. Call the DB lead instead, they can recover the WAL.
09:42 Priya: agreed. Updating the runbook step 2.
P
