library("RPostgreSQL")
library("ggplot2")

db = "tordir"
dbuser = "ernie"
dbpassword= ""

plot_bandwidth_uptime <- function() {

  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)


  q <- paste("select (round(d.uptime/864000.0)*10)::integer as uptime, ",
    "    (avg(d.bandwidthavg)/131072.0)::integer as bwavg ",
    "from descriptor d ",
    "join statusentry s on d.descriptor=s.descriptor ",
    "where d.bandwidthavg is not null ",
    "    and date(s.validafter) >= '2010-02-01' ",
    "    and date(s.validafter) <= '2010-02-05' ",
    "group by (round(d.uptime/864000.0)*10)::integer ")

  rs <- dbSendQuery(con, q)
  bandwidth <- fetch(rs,n=-1)

  ggplot(bandwidth) +
    geom_bar(aes(x=uptime,y=bwavg), stat="identity") +
    scale_x_continuous(name="Uptime (days)") +
    scale_y_continuous(name="Bandwidth (Mbit/s)") +
    opts(title="Bandwidth to uptime distribution (10 day intervals)")

  ggsave(filename="png/bandwidth-uptime-bargraph.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

plot_bandwidth_uptime()
