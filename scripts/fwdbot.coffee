#
# Call fowarding APIs
# Reponse to chatting user
# cheers!
# http://10.0.14.199:8080/opusfwd/fwdchatapi/getHBL
# {
#  "usrId": "lucduong",
#  "BHLNo": "OOEH-800268"
# }

# http://10.0.14.199:8080/opusfwd/fwdchatapi/getRevenue
# {
#  "fmDtStr": "May-01-2017",
#  "toDtStr": "May-31-2017",
#  "usrId": "cltmaster"
# }
# {
#  "usrId": "cltmaster",
#  "monthYear": "Oct-2016"
# }


url = "http://dounets.com:5050"

basicBLInfo = ['Shipper', 'Consignee', 'POL', 'ETD', 'POD', 'Carrier', 'Vessel Name']
allBLInfo = ['Shipper', 'Consignee', 'POL', 'ETD', 'POD', 'Carrier', 'Vessel Name']

genList = (item) ->
  sarr = []
  # keywords = Object.keys(item)
  # num_item = keywords.length
  # i = 0
  # while i < num_item
  #   itm = "#{keywords[i]}" + ' ' + "`#{item[keywords[i]]}`"
  #   sarr.push itm
  #   i++  
  sarr.push "[Shipper]" + ' ' + "`#{item.shpr_trdp_nm}`"
  sarr.push "[Consignee]" + ' ' + "`#{item.cnee_trdp_nm}`"
  sarr.push "[POL]" + ' ' + "`#{item.pol_nm}`"
  sarr.push "[POD]" + ' ' + "`#{item.pod_nm}`"
  sarr.push "[ETD]" + ' ' + "`#{item.etd_dt_tm}`"
  sarr.push "[Carrier]" + ' ' + "`#{item.lnr_trdp_nm}`"
  sarr.push "[Vessel name]" + ' ' + "`#{item.trnk_vsl_nm}`"
  return sarr.join("\n")

module.exports = (robot) ->
  
  robot.hear /Search BL (.*)/i, (res) ->
    blNo = res.match[1]
    param = {
        "usrId": "lucduong",
        "BHLNo": blNo
    }
    robot.http("#{url}/opusfwd/fwdchatapi/getHBL")
      .header('Content-Type', 'application/json')
      .post(JSON.stringify(param)) (err, _res, body) ->
        # error checking code here
        if err
            res.send "Could not find BL #{blNo}"
            return

        result = JSON.parse body
        arr = genList result.result
        msg = "_BH/L No._ `#{blNo}`\n" + arr + "\n\n[Additional Info](#{url}/opusfwd)"
        res.send (msg)


  robot.hear /Revenue(s?) from (.*) to (.*)/i, (res) ->
    startDate = res.match[2]
    # if (startDate NOT correct format)
    #   res.send "start date should be like this: {date format}"
    #   return
      
    endDate = res.match[3]
    # if (endDate NOT correct format)
    #   res.send "end date should be like this: {date format}"
    #   return
    
    param = {
      "fmDtStr": startDate,
      "toDtStr": endDate
      "usrId": "cltmaster"
    }

    robot.http("#{url}/opusfwd/fwdchatapi/getRevenue")
      .header('Content-Type', 'application/json')
      .post(JSON.stringify(param)) (err, _res, body) ->
        # error checking code here
        if err
            res.send "Could not get revenue!"
            return

        result = JSON.parse body
        res.send ("Revenue: " + "`#{result.total}`")


  robot.hear /Revenue(s?) (.*)/i, (res) ->
    monthYear = res.match[2]
    # if (startDate NOT correct format)
    #   res.send "start date should be like this: {date format}"
    #   return
      
    param = {
      "usrId": "cltmaster",
      "monthYear": monthYear
    }

    robot.http("#{url}/opusfwd/fwdchatapi/getRevenue")
      .header('Content-Type', 'application/json')
      .post(JSON.stringify(param)) (err, _res, body) ->
        # error checking code here
        if err
            res.send "Could not get revenue!"
            return

        result = JSON.parse body
        res.send ("Revenue: " + "`#{result.total}`")
  