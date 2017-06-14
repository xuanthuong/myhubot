#
# Call fowarding APIs
# Reponse to chatting user
# cheers!
# /fwdchatapi/{userId}/getHBLList/
# /fwdchatapi/{userId}/getRevenue/
#
url = "http://10.0.14.199:8080"

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
        "BHLNo": "OOEH-800268"
    }
    robot.http("#{url}/opusfwd/fwdchatapi/getHBL")
      .header('Content-Type', 'application/json')
      .post(JSON.stringify(param)) (err, _res, body) ->
        # error checking code here
        if err
            res.send "Could not find BL #{blNo}"
            return

        result = JSON.parse body
        res.send ("_BH/L No._ `#{blNo}`\n" + genList result.result)
  