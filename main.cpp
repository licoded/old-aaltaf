#include "formula/aalta_formula.h"
#include "ltlfchecker.h"
#include "carchecker.h"
#include "solver.h"
#include <stdio.h>
#include <string.h>


#define MAXN 100000
char in[MAXN];

using namespace aalta;

void 
print_help ()
{
	cout << "usage: ./aalta_f [-e|-v|-blsc|-t|-h] [\"formula\"]" << endl;
	cout << "\t -e\t:\t print example when result is SAT" << endl;
	cout << "\t -v\t:\t print verbose details" << endl;
	cout << "\t -blsc\t:\t use the BLSC checking method; Default is CDLSC" << endl;
	cout << "\t -t\t:\t print weak until formula" << endl;
	cout << "\t -h\t:\t print help information" << endl;
}

void
ltlf_sat (int argc, char** argv)
{
	bool verbose = false;
	bool evidence = false;
	int input_count = 0;
	bool blsc = false;
	bool print_weak_until_free = false;

	aalta_formula::TAIL(); // set tail id to be 1
    aalta_formula(aalta_formula::Not, nullptr, aalta_formula::TAIL()).unique(); // set tail id to be 1
    aalta_formula::FALSE(); // set FALSE id to be 2
    aalta_formula::TRUE(); // set TRUE id to be 3
    // aalta_formula("a").unique();
    // aalta_formula(aalta_formula::Not, nullptr, aalta_formula("a").unique()).unique(); // set tail id to be 1
    // aalta_formula(aalta_formula::Next, nullptr, aalta_formula("a").unique()).unique(); // set tail id to be 1
    // aalta_formula("b").unique();
    // aalta_formula(aalta_formula::Not, nullptr, aalta_formula("b").unique()).unique(); // set tail id to be 1
    // aalta_formula(aalta_formula::Next, nullptr, aalta_formula("b").unique()).unique(); // set tail id to be 1

	const int MAX_VARIABLE_NUM = 40;

	for(int i = 0; i < 10 && i <MAX_VARIABLE_NUM; i++)
	{
		char s1[10]="p0";
		s1[1] = i;
		aalta_formula(s1).unique();
		aalta_formula(aalta_formula::Not, nullptr, aalta_formula(s1).unique()).unique();  // set tail id to be 1
		aalta_formula(aalta_formula::Next, nullptr, aalta_formula(s1).unique()).unique(); // set tail id to be 1
	}
	for(int i = 10; i < 100 && i <MAX_VARIABLE_NUM; i++)
	{
		char s2[10]="p10";
		s2[1] = i/10;
		s2[2] = i%10;
		aalta_formula(s2).unique();
		aalta_formula(aalta_formula::Not, nullptr, aalta_formula(s2).unique()).unique();  // set tail id to be 1
		aalta_formula(aalta_formula::Next, nullptr, aalta_formula(s2).unique()).unique(); // set tail id to be 1
	}
	
	for (int i = argc; i > 1; i --)
	{
		if (strcmp (argv[i-1], "-v") == 0)
			verbose = true;
		else if (strcmp (argv[i-1], "-e") == 0)
			evidence = true;
		else if (strcmp (argv[i-1], "-blsc") == 0)
			blsc = true;
		else if (strcmp (argv[i-1], "-t") == 0)
			print_weak_until_free = true;
		else if (strcmp (argv[i-1], "-h") == 0)
		{
			print_help ();
			exit (0);
		}
		else //for input
		{
			if (input_count > 1)
			{
				printf ("Error: read more than one input!\n");
        		exit (0);
			}
			strcpy (in, argv[i-1]);
			input_count ++;
		}
	}
	if (input_count == 0)
	{
		puts ("please input the formula:");
    	if (fgets (in, MAXN, stdin) == NULL)
    	{
        	printf ("Error: read input!\n");
        	exit (0);
      	}
	}


  aalta_formula* af;
  //set tail id to be 1
  af = aalta_formula::TAIL ();  
  af = aalta_formula(in, true).unique();
	if (print_weak_until_free)
	{
		cout << af->to_string () << endl;
		return;
	}
  
  af = af->nnf ();
	af = af->add_tail ();
  af = af->remove_wnext ();
  af = af->simplify ();
  af = af->split_next ();
  cout << af->to_string () << endl;
  
  
  
  //LTLfChecker checker (af, verbose);
  // A  t (af, verbose);
  /*
  LTLfChecker *checker;
  if (!blsc)
  	checker = new CARChecker (af, verbose, evidence);
  else
  	checker = new LTLfChecker (af, verbose, evidence);

  bool res = checker->check ();
  printf ("%s\n", res ? "sat" : "unsat");
  if (evidence && res)
  	checker->print_evidence ();
  delete checker;
  */
  if (blsc)
  {
	  LTLfChecker checker (af, verbose, evidence);
	  bool res = checker.check ();
	  printf ("%s\n", res ? "sat" : "unsat");
	  if (evidence && res)
		  checker.print_evidence ();
  }
  else
  {
	CARChecker checker (af, verbose, evidence);
	bool res = checker.check ();
	printf ("%s\n", res ? "sat" : "unsat");
	if (evidence && res)
		checker.print_evidence ();
  }
  aalta_formula::destroy();
}


int
main (int argc, char** argv)
{
  ltlf_sat (argc, argv);
  return 0;
  

}
