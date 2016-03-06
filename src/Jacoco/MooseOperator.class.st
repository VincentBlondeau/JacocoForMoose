"
MooseOperator is a task that will act on a model. As any other task, its subclasses will specify their main execution entry point in the method basicRun.


"
Class {
	#name : #MooseOperator,
	#superclass : #MooseTask,
	#instVars : [
		'model',
		'args'
	],
	#category : #Jacoco
}

{ #category : #'instance creation' }
MooseOperator class >> on: aMooseModel [ 
	 
	^(self new) 
		model: aMooseModel; 
		yourself
]

{ #category : #running }
MooseOperator class >> runOn: aMooseModel [ 
	 
	^(self on: aMooseModel) run
]

{ #category : #running }
MooseOperator class >> runWithProgressOn: aMooseModel [
	^ (self on: aMooseModel) runWithProgress
]

{ #category : #accessing }
MooseOperator >> model [ 
	 
	^model
]

{ #category : #accessing }
MooseOperator >> model: aMooseModel [ 
	 
	^model := aMooseModel
]
