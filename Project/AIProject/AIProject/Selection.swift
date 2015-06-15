//
//  Selection.swift
//  AIProject
//
//  Created by Muhammad Raza on 15/06/2015.
//  Copyright (c) 2015 Muhammad Raza. All rights reserved.
//

import UIKit

public struct Selections {
    public static func Truncation<I: IndividualType>(truncationPoint: Double)(pop:[Score<I>], fitnessKind: FitnessKind, count:Int) -> [I] {
        let truncationCount = Int(floor(truncationPoint * Double(pop.count)))
        
        let slice = pop[0..<count]
        let result = Array(slice)
        
        return map(result) { $0.individual }
    }
    
    public static func Random<I:IndividualType>(pop: [Score<I>], fitnessKind: FitnessKind, count: Int) -> [I] {
        var selected = [I]()
        
        for _ in 0..<count {
            selected.append(pickRandom(from:pop).individual)
        }
        
        return selected
    }
    
    public static func Tournament<I:IndividualType>(size:Int)(pop: [Score<I>], fitnessKind: FitnessKind, count: Int) -> [I] {
        var selection = [I]()
        
        let sortLambda = { (a:Score<I>, b:Score<I>) -> Bool in
            return fitnessKind.comparsionOp(lhs: a.fitness, rhs: b.fitness)
        }
        
        iterateWhile({ return $0 < count }, 0) {i in
            let individuals = (0..<size).map{ _ -> Score<I> in
                return pickRandom(from: pop)
            }
            let sorted = individuals.sorted(sortLambda)
            selection.append(sorted.first!.individual)
            
            return selection.count
        }
        
        return selection
    }
    
    //RouletteWheel 
    /*for all members of population
    sum += fitness of this individual
    end for
    
    for all members of population
    probability = sum of probabilities + (fitness / sum)
    sum of probabilities += probability
    end for
    
    loop until new population is full
    do this twice
    number = Random between 0 and 1
    for all members of population
    if number > probability but less than next probability
    then you have been selected
    end for
    end
    create offspring
    end loop
    http://stackoverflow.com/questions/177271/roulette-selection-in-genetic-algorithms
    */
    public static func RouletteWheel<I:IndividualType>(pop: [Score<I>], fitnessKind: FitnessKind, count: Int) -> [I] {
        let fitnesses = pop.map({ $0.fitness })
        
        let cumulative = scanl1(fitnesses) { acc, val -> Double in
            acc + fitnessKind.adjustedFitness(val)
        }
    
        var selection = [I]()
        
        while selection.count < count {
            let randomFitness = Double(randomP()) * cumulative.last!
            let idx = insertionPoint(fitnesses, randomFitness)
            
            selection.append(pop[idx].individual)
        }
        return selection
    }
    
}