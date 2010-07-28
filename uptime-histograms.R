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
  "    extract('epoch' from d.published)))/3600)::INTEGER as uptime, ",
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
    geom_histogram(binwidth=24) +
    scale_x_continuous(limits=c(0, 1000))

  ggsave(filename="./exit-uptime-histogram.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

plot_version_uptime <- function() {
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste("select ((d.uptime + ",
    "    (extract('epoch' from s.validafter) - ",
    "    extract('epoch' from d.published))) / 3600)::INTEGER as uptime, ",
    "    substring(platform, 5, 5) as version ",
    "from descriptor d ",
    "join statusentry s on d.descriptor=s.descriptor ",
    "where uptime is not null ",
    "    and date(s.validafter) >= '2010-02-01' ",
    "    and date(s.validafter) <= '2010-03-01' ")

  rs <- dbSendQuery(con, q)
  uptime <- fetch(rs,n=-1)

  ggplot(uptime, aes(x=uptime, fill=version)) +
    geom_histogram(binwidth=24) +
    scale_x_continuous(limits=c(0,1000))

  ggsave(filename="./version-uptime-histogram.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

plot_platform_uptime <- function()  {
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste("select ((d.uptime + ",
    "    (extract('epoch' from s.validafter) - ",
    "    extract('epoch' from d.published))) / 3600)::INTEGER as uptime, ",
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

  ggplot(uptime, aes(y=uptime, x=platform, fill=platform))  +
    geom_boxplot()
#    geom_histogram(binwidth=1) +
#    scale_x_continuous(limits=c(0,1000))

  ggsave(filename="./platform-uptime-boxplot.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

#plot_version_uptime()
plot_platform_uptime()
