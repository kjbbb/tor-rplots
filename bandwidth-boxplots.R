
library("RPostgreSQL")
library("ggplot2")

db = "tordir"
dbuser = "ernie"
dbpassword= ""

plot_bandwidth_versions <- function() {
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste("select d.bandwidthavg/131072.0 as bandwidthavg, ",
    "    substring(d.platform, 5, 5) as version ",
    "from descriptor d ",
    "join statusentry s on d.descriptor=s.descriptor ",
    "where bandwidthavg is not null ",
    "and s.validafter = '2010-02-19 08:00:00' ")

  rs <- dbSendQuery(con, q)
  bandwidth <- fetch(rs,n=-1)

  ggplot(bandwidth, aes(y=bandwidthavg, x=version, fill=version)) +
    geom_boxplot() +
    scale_y_continuous(limits=c(0, 10))

  ggsave(filename="png/bandwidth-versions-boxplot.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

plot_bandwidth_platforms <- function()  {

  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste("select d.bandwidthavg/131072.0 as bandwidthavg, ",
    "    (case when platform like '%Windows%' then 'Windows' ",
    "     when platform like '%Linux%' then 'Linux' ",
    "     when platform like '%FreeBSD%' then 'FreeBSD' ",
    "     when platform like '%Darwin%' then 'Darwin' else 'Other' end) as platform ",
    "from descriptor d ",
    "join statusentry s on d.descriptor=s.descriptor ",
    "where bandwidthavg is not null ",
    "and date(s.validafter) = '2010-02-01'")

  rs <- dbSendQuery(con, q)
  bandwidth <- fetch(rs,n=-1)

  ggplot(bandwidth, aes(y=bandwidthavg, x=platform, fill=platform)) +
    geom_boxplot() +
    scale_y_continuous(limits=c(0, 10))

  ggsave(filename="png/bandwidth-platforms-boxplot.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

#plot_bandwidth_versions()
plot_bandwidth_platforms()
