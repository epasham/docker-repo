job('docker-do-cleanup') {
    displayName('Docker do clean-up')
    description('Cleans up all left-over docker items to avoid the hard-drive filling up')

    // Run Once per day
    triggers {
        cron('H H * * *')
    }

    steps {
        shell('''
set -exu

docker system df -v

docker system prune -af --filter "until=24h"
docker volume prune -f

docker system df -v
df -h
        ''')
    }

    logRotator {
        daysToKeep(7)
    }
}
