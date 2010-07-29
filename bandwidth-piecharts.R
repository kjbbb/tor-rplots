library("RPostgreSQL")
library("ggplot2")

db = "tordir"
dbuser = "ernie"
dbpassword= ""

plot_bandwidth_versions <- function() {

  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste("select sum(d.bandwidthavg) as bandwidthsum, ",
    "    substring(d.platform, 5, 5) as version ",
    "from descriptor d ",
    "join statusentry s on d.descriptor=s.descriptor ",
    "where date(s.validafter) = '2010-03-01' ",
    "group by substring(d.platform, 5, 5)")

  rs <- dbSendQuery(con, q)
  bandwidth <- fetch(rs,n=-1)

  ggplot(bandwidth, aes(x="", y=bandwidthsum, fill=version)) +
    geom_bar() +
    coord_polar("y")

  ggsave(filename="png/bandwidth-versions-piechart.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

plot_bandwidth_versions()
