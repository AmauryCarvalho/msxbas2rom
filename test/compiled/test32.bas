10 ON INTERVAL=60 GOSUB 60
20 INTERVAL ON
30 IF STRIG(0) = 0 THEN 30
40 INTERVAL OFF
50 END
60 K=K+1:PRINT K;"seconds"
70 RETURN


