library("RPostgreSQL")
library("ggplot2")

db = "tordir"
dbuser = "ernie"
dbpassword= ""

plot_exit_uptime <- function() {
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste("select ((d.uptime + ",
  "    (extract('epoch' from s.validafter) - ",
  "    extract('epoch' from d.published)))/86400)::INTEGER as uptime, ",
  "    ((case when isexit=true then 't' else 'f' end) || ",
  "    (case when isguard=true then 't' else 'f' end)) as guardexit ",
  "from descriptor d ",
  "join statusentry s on d.descriptor=s.descriptor ",
  "where uptime is not null ",
  "    and date(s.validafter) >= '2010-02-01' ",
  "    and date(s.validafter) <= '2010-03-01' ")


  rs <- dbSendQuery(con, q)
  uptime <- fetch(rs,n=-1)

  ggplot(uptime, aes(x=uptime, fill=guardexit)) +
    geom_histogram(binwidth=20, position="dodge") +
    scale_x_continuous(name="Uptime (days)") +
    opts(title="Guard and exit flag uptime histogram")

  ggsave(filename="png/exit-uptime-histogram.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

plot_version_uptime <- function() {
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste("select ((d.uptime + ",
    "    (extract('epoch' from s.validafter) - ",
    "    extract('epoch' from d.published))) / 86400)::INTEGER as uptime, ",
    "    substring(platform, 5, 5) as version ",
    "from descriptor d ",
    "join statusentry s on d.descriptor=s.descriptor ",
    "where uptime is not null ",
    "    and date(s.validafter) >= '2010-02-01' ",
    "    and date(s.validafter) <= '2010-03-01' ")

  rs <- dbSendQuery(con, q)
  uptime <- fetch(rs,n=-1)

  ggplot(uptime, aes(x=uptime, fill=version)) +
    geom_histogram(binwidth=20, position="dodge") +
    scale_x_continuous(name="Uptime (days)") +
    opts(title="Version uptime histogram")

  ggsave(filename="png/version-uptime-histogram.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

plot_platform_uptime <- function()  {
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste("select ((d.uptime + ",
    "    (extract('epoch' from s.validafter) - ",
    "    extract('epoch' from d.published)))/86400)::INTEGER as uptime, ",
    "    (case when platform like '%Windows%' then 'Windows' ",
    "        when platform like '%Linux%' then 'Linux' ",
    "        when platform like '%FreeBSD%' then 'FreeBSD' ",
    "        when platform like '%Darwin%' then 'Darwin' else 'other' end) as ",
    "        platform ",
    "from descriptor d ",
    "join statusentry s on d.descriptor=s.descriptor ",
    "where uptime is not null ",
    "    and date(s.validafter) >= '2010-02-01' ",
    "    and date(s.validafter) <= '2010-03-01'")

  rs <- dbSendQuery(con, q)
  uptime <- fetch(rs,n=-1)

  ggplot(uptime, aes(x=uptime, fill=platform))  +
    geom_histogram(binwidth=20, position="dodge") +
    scale_x_continuous(name="Uptime (days)") +
    opts(title="Platform uptime histogram")

  ggsave(filename="png/platform-uptime-histogram.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

plot_version_uptime()
plot_platform_uptime()
plot_exit_uptime()
