class MidmtimtpinfoController < ApplicationController
    def index
	   midmtpinfo= Midmtpinformation.find_by_sql("SELECT \"ID\", \"Date\", \"MTI_Volume_Testing_UAT\", \"Volumn_Testing_UAT\", 
       \"Solution_Source_Logged\", \"Control_Period_Benchmarking\", \"Artifacts_Frozen_Rlease_Locked\", 
       \"MTP\"
       FROM mtp_calendars;")
	   midmtphash={}
	   midmtphash[:releasedate]={}
	   midmtphash[:releasedate][:MTI]=midmtpinfo[0]["MTI_Volume_Testing_UAT"]
	   midmtphash[:releasedate][:UAT]=midmtpinfo[0]["Volumn_Testing_UAT"]
	   midmtphash[:releasedate][:SSL]=midmtpinfo[0]["Solution_Source_Logged"]
	   midmtphash[:releasedate][:ControlPeriod]=midmtpinfo[0]["Control_Period_Benchmarking"]
	   midmtphash[:releasedate][:Frozen]=midmtpinfo[0]["Artifacts_Frozen_Rlease_Locked"]
	   midmtphash[:releasedate][:MTP]=midmtpinfo[0]["MTP"]
	   
	   
	   midmtphash[:midmtimtpinfo]=[]
	   midmtphash[:midmtimtpinfo].push({
                :MID=>"11886",
                :EnvironmentITG=>"BER",
                :MTIDate=>"2015-12-10",
                :EnvironmentJAD=>"JAD",
                :MTPDateJAD=>"2015-12-18",
                :EnvironmentZEO=>"ZEO",
                :MTPDateZEO=>"2015-12-18",
                :EnvironmentEMR=>"EMR",
                :MTPDateEMR=>"2015-12-18"

            },
            {
                :MID=>"21886",
                :EnvironmentITG=>"BER",
                :MTIDate=>"2015-12-15",
                :EnvironmentJAD=>"JAD",
                :MTPDateJAD=>"2015-12-21",
                :EnvironmentZEO=>"ZEO",
                :MTPDateZEO=>"2015-12-18",
                :EnvironmentEMR=>"EMR",
                :MTPDateEMR=>"2015-12-22"

            },
            {
                :MID=>"21823",
                :EnvironmentITG=>"BER",
                :MTIDate=>"2015-12-11",
                :EnvironmentJAD=>"JAD",
                :MTPDateJAD=>"2015-12-17",
                :EnvironmentZEO=>"ZEO",
                :MTPDateZEO=>"2015-12-17",
                :EnvironmentEMR=>"EMR",
                :MTPDateEMR=>"2015-12-18"

            })
	   
	render json:midmtphash.to_json
	end
end
