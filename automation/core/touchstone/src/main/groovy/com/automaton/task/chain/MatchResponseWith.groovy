package com.automaton.task.chain

import java.util.Map;

class MatchResponseWith implements Executor{

    MatchResponseWith(Executor next){
        super(next)
    }

    def execute(Map automaton){
        
        if(matchResponseWith(automaton)){
            
        }

        super.execute(automaton)
    }
}
