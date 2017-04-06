heroku_get_db() {
  app=$1
  source .env.development && \
    heroku pg:backups capture --app $app && \
    curl -o db.dump `heroku pg:backups public-url --app $app` && \
    pg_restore --no-owner -c -d $DATABASE db.dump
}
