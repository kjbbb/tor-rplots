
library("RPostgreSQL")
library("ggplot2")

db = "tordir"
dbuser = "ernie"
dbpassword= ""

plot_bandwidth_versions <- function() {
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste("select d.bandwidthavg, ",
    "    substring(d.platform, 5, 5) as version ",
    "from descriptor d ",
    "join statusentry s on d.descriptor=s.descriptor ",
    "where bandwidthavg is not null ",
    "    and date(s.validafter) >= '2010-02-01' ",
    "    and date(s.validafter) <= '2010-03-01' ")

  rs <- dbSendQuery(con, q)
  bandwidth <- fetch(rs,n=-1)

  ggplot(bandwidth, aes(x=bandwidthavg, fill=version)) +
    geom_histogram() +
    scale_x_log10() +
    coord_trans(x="log10")

  ggsave(filename="./bandwidth-versions-histogram.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

plot_bandwidth_platforms <- function()  {

  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste("select d.bandwidthavg/131072, ",
    "    (case when platform like '%Windows%' then 'Windows' ",
    "     when platform like '%Linux%' then 'Linux' ",
    "     when platform like '%FreeBSD%' then 'FreeBSD' ",
    "     when platform like '%Darwin%' then 'Darwin' else 'Other' end) as platform ",
    "from descriptor d ",
    "join statusentry s on d.descriptor=s.descriptor ",
    "where bandwidthavg is not null ",
    "    and date(s.validafter) >= '2010-02-01' ",
    "    and date(s.validafter) <= '2010-03-01'")

  rs <- dbSendQuery(con, q)
  bandwidth <- fetch(rs,n=-1)

  ggplot(bandwidth, aes(x=bandwidthavg, fill=platform)) +
    geom_histogram() +
    scale_x_log10() +
    coord_trans(x="log10")

  ggsave(filename="./bandwidth-platforms-histogram.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

#plot_bandwidth_versions()
plot_bandwidth_platforms()
