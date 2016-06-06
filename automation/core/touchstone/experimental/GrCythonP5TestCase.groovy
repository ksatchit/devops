package com.automaton.experimental

@Grab('com.aestasit.infrastructure.sshoogr:sshoogr:0.9.25')
@Grab('com.cb:touchstone:0.0.2')

import com.automaton.launcher.AutomatonSpecsRunner;
import static groovy.json.JsonOutput.prettyPrint
import static groovy.json.JsonOutput.toJson

def cythonMacOpts = {
    defaultHost = '20.10.112.21'
    defaultUser = 'root'
    defaultPassword = 'test123'
}

def elastistorMacOpts = {
    defaultHost = '20.10.48.140'
    defaultUser = 'root'
    defaultPassword = 'test'
}

def Map container = [:]

def automaton = {
    
    ssh
    
    ssh {
        to(elastistorMacOpts, 'Remove lock file @ elastistor')
        
        run('rm /tenants/f7ec4eb1486c3aa6a4bafaa12d93e084/PoolRaidz1/Account1TSM1/amit.has')
        
    }

    ssh('task-002') {
        to(elastistorMacOpts, 'Restart lockd service @ elastistor')
        
        run('restart lockd')
        
        storeAs('task-002.output', [])
    }

    ssh {
        to(cythonMacOpts, 'Trigger cython test cases')
        
        run('cd /cthon04 && pwd')
        
        storeAs('task-003.output', container)

        then('is it cthon05', { contains("cthon05") ? "'$it' contains cthon05." : "'$it' does not have cthon05." })

        then('verify if numeric', { isNumber() ? "'$it' is a number." : "'$it' is a string." })

        then('verify if empty', { isEmpty() ? "'$it' is an empty thing." : "'$it' is a filled stuff." })
        
        storeAs('task-003.output2', container)
        
    }

    ssh([repeat: 4, interval: 10000]) {
        to(cythonMacOpts, 'Verify cython test cases by sampling at periodic intervals')
        
        run('cd /cthon04 && cat abc.out')
        
        then { container.get('task-003.output').contains("cthon04") ? "Yes. It is cthon04." : "No. It is not cthon04." }
    }

    ssh('task-005') {
        to(elastistorMacOpts, 'Enable lock file @ elastistor')
        
        run('touch /tenants/f7ec4eb1486c3aa6a4bafaa12d93e084/PoolRaidz1/Account1TSM1/amit.has')
        
        storeAs('task-005.output', container)
    }

    ssh('task-006', !container.get('task-005.output').contains('No such file')) {
        
        to(elastistorMacOpts, 'Restart lockd service @ elastistor')
        
        run('restart lockd')
    }
}

AutomatonSpecsRunner runner = new AutomatonSpecsRunner()

println prettyPrint(toJson(runner.specification(automaton)))
