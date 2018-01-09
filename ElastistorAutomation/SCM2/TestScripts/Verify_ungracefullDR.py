#!/usr/bin/env python
#title           :Verify_ungracefullDR.py
#description     :This script is run to verify ungracefull HA during DR.
#author          :Sudarshan D
#date            :20170913
#version         :1
#usage           :python Verify_ungracefullDR.py
#notes           :
#python_version  :2.7
#==============================================================================

from SCM2.GUIConfig import GuiConfig as const
from SSHConnection import SSHConnection
import time, sys, Logging, os

def main():
    filename = os.path.abspath(__file__)
    log = Logging.getLogger(filename, 'UngracefullHA_DR')
    try:
        user = const.node_username
        pwd = const.node_password
        host2 = const.Node2_IP
        vsm_ip = const.VSM1Ip
        SSH = SSHConnection()
        time.sleep(180)
        out1 = SSH.cbdpctl_status(user, pwd, host2, vsm_ip)
        print out1
        bytestransfered = out1[1]
        time.sleep(60)
        out2 = SSH.cbdpctl_status(user, pwd, host2, vsm_ip)
        print out2
        cstatus = out2[0]
        cbytestransfered = out2[1]
        if cstatus == "Transferring" or int(cbytestransfered) > int(bytestransfered):
            print "Pass: DR transfer resumed successfully"
            log.info("Pass: DR transfer resumed successfully")
        elif cstatus == "Uptodate":
            print "Pass: DR resumed and completed successfully"
            log.info("Pass: DR resumed and completed successfully")
        else:
            print "Fail: DR resume failed"
            log.error("Fail: DR resume failed")

    except Exception as e:
        log.error("Exception:TC: Verify ungracefullDR")
        print str(e)
if __name__ == '__main__':
    main()
