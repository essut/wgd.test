# this program generates polynomials for the GD model and uses memoisation to reduce memory consumption and computational time.

import argparse

parser = argparse.ArgumentParser()
parser.add_argument('N', type=int)
parser.add_argument('M', type=int)
parser.add_argument('--balanced', action='store_true')
parser.add_argument('--forced_alive', action='store_true')
parser.add_argument('--parental_specific', action='store_true')
args = parser.parse_args()

N = args.N
M = args.M
balanced = args.balanced
forced_alive = args.forced_alive
parental_specific = args.parental_specific

import sage.libs.ecl
sage.libs.ecl.ecl_eval("(ext:set-limit 'ext:heap-size 0)")

if balanced:
  var('s,a')
  def f(s): return a +(1-2*a)*s+a*s^2 # the recursive generating function

if not balanced:
  var('s,a,b,c')
  def f(s): return a+b*s+c*s^2 # the recursive generating function

prefix = "/Users/lmcintosh/GD/GFS/B_"+str(balanced)+"_FA"+str(forced_alive)+"_PS"+str(parental_specific)+"_"
suffix = "_12_dec"
filename_output = prefix+"N"+str(N)+"_M"+str(M)+suffix

if not os.path.isfile(filename_output):
  if N == 0 and M == -1:
    if parental_specific:
      expr = s
    else:
      expr = s^2
    save(expr,filename_output)
  else:
    # load the preceding solution (do this dynamically to minimise memory consuption as it is the limiting factor)
    if M == -1:
      filename_input = prefix+"N"+str(N-1)+"_M"+str(M)+suffix
    else:
      filename_input = prefix+"N"+str(N)+"_M"+str(M-1)+suffix
    GFS = load(filename_input)

    if M == 0:
      # then double the genome
      expr = GFS.substitute(s==s^2)
    else:
      expr = GFS.substitute(s == f(s)) 
      if forced_alive:
        expr = expr + GFS.substitute(s == 0)*(s-1)

    save(expr,filename_output)
else:
  expr = load(filename_output)

x=expr.coefficients(s)
for j in range(len(x)):
  prefix = "/Users/lmcintosh/GD/GFS/B_"+str(balanced)+"_FA"+str(forced_alive)+"_PS"+str(parental_specific)+"_"+"N"+str(N)+"_M"+str(M)+"/"
  if not os.path.exists(prefix):
    os.makedirs(prefix)
  filename = prefix+"c"+str(x[j][1]) + suffix
  output = open(filename,'w')
  output.write(str(x[j][0]))
  output.close()
