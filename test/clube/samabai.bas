1 dim a(3), b(3), c(3), d(3), e(3), f(3), p(3) 
2 a(0)= 0.00 : b(0)= 0.00 : c(0)= 0.00 : d(0)=0.16 : e(0)=0.00 : f(0)=0.00 : p(0)=0.02
3 a(1)= 0.85 : b(1)= 0.04 : c(1)=-0.04 : d(1)=0.85 : e(1)=0.00 : f(1)=1.60 : p(1)=0.84
4 a(2)= 0.20 : b(2)=-0.26 : c(2)= 0.23 : d(2)=0.22 : e(2)=0.00 : f(2)=1.60 : p(2)=0.07
5 a(3)=-0.15 : b(3)= 0.28 : c(3)= 0.26 : d(3)=0.24 : e(3)=0.00 : f(3)=0.44 : p(3)=0.07
6 n=3
100 x=0 : y=0
110 screen 2
120 for t = 0 to 10000
130   pset(x*20+128,y*20)
140   r = rnd(1)
145   s = 0
150   for j=0 to n
151     s = s + p(j)
152     if r<s then i=j:goto 154
153   next j
154   u = x
155   x = a(i)*x + b(i)*y + e(i)
160   y = c(i)*u + d(i)*y + f(i)
170 next t
