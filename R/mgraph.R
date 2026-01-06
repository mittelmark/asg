#' @title create mgraph objects
#' 
#' @description This function creates a new graph object based on either
#'  an adjacency matrix or for a given graph type.
#' 
#' @param x either a adjacency matrix or an adjacency list, if not given a type must be given
#' @param type a graph type, one of 'angie', 'band', 'barabasi', 'circle', 'cluster', 'hubs', 'orion','random', 'regular' or 'werner', default: 'random'
#' @param mode either 'undirected' or 'directed', default: 'directed'
#' @param nodes number of nodes for a given type, default: 10
#' @param edges number of edges for a given type, not used for type "barabasi", default: 12
#' @param m number of edges added in each iteration of type is 'barabasi', default: 1
#' @param k the degree for a regular graph, or the number of clusters for a cluster graph or the number of hubs for a hubs graph, default: 2
#' @param p the probabilty for edges if type is 'gnp'
#' @param power the power for preferential attachment if type is 'barabasi', 1 is linear preferential attachment, below one is sublinear, smaller hubs, 0 is no hubs, above 1 is super linear with super hubs, default: 1
#' @param input number of input nodes for random graphs, default: 2
#'
#' @examples
#' M <- matrix(0,nrow=7,ncol=7)
#' rownames(M)=colnames(M)=LETTERS[1:7]
#' M[c('A','B'),'C']=1
#' M['C','D']=1
#' M['D',c('E','F')]=1
#' M['E','F']=1
#' W=mgraph.new(M)
#' set.seed(125)
#' R = mgraph.new(type="random",nodes=8,edges=9)
#' summary(R)
#' A = mgraph.new(type="angie",nodes=8,edges=9)
#' C = mgraph.new(type="circle",nodes=8)
#' par(mfrow=c(3,2),mai=rep(0.3,4))
#' plot(W,layout="sam",vertex.color=mgraph.nodeColors(W))
#' plot(R,layout="circle")
#' plot(A,layout="circle")
#' plot(C,layout="circle")
#' O=mgraph.new(type="orion")
#' plot(O,layout='orion',vertex.colors=mgraph.nodeColors(O))
#' plot(mgraph.d2u(O),layout="orion")
#' @export
#' 
#' @author: Detlef Groth, Cedric Moris
#' 
mgraph.new <- function (x=NULL,type="random", mode="directed", nodes=10, 
                        edges=12, m=1, k=3, p=NULL, power=1,input=2) {
    types=c("angie","band","barabasi","circle","cluster","gnp","hubs","random","orion","regular","werner")
    i=pmatch(type,types)
    if (is.na(i)) {
        stop(paste("Unkown type: Known types are: '",paste(types,collapse="', '"),"'!",sep=""))
    }
    type=types[i]
    if (!is.null(x[1])) {
        if (is.matrix(x) & nrow(x)==ncol(x) & all(rownames(x)== colnames(x))) {
            class(x)="mgraph"
        }
        if (is.null(rownames(x)[1])) {
            nms=mgraph.autonames(nrow(x))
            rownames(x)=colnames(x)=nms
        }
    } else if (is.null(x[1])) {
        if (is.null(type)) {
            stop("Error: Either a matrix or a type must be given for mgraph$new!")
        }
        x=matrix(0,nrow=nodes,ncol=nodes)
        nms=mgraph.autonames(nodes)
        rownames(x)=colnames(x)=nms
        if (type == "random") {
            v=1:length(x[upper.tri(x)])
            idx=sample(v,edges)
            x[upper.tri(x)][idx]=1
            x=mgraph.u2d(mgraph.d2u(x),input=input)
        } else if (type %in% c("band","circle")) {
            for (i in 1:((nrow(x)-1))) {
                x[i,i+1]=1
            }
            if (type == "circle") {
                x[nrow(x),1]=1
            }
        } else if (type == "barabasi") {
            x[2, 1]=1
            for (n in 3:ncol(x)) {
                if (m==n) {
                    sel=n-1
                } else {
                    sel=m
                }
                deg=mgraph.degree(x)^power
                # preferential attachment to nodes with higher degree
                idx=sample(1:(n-1),sel,prob=deg[1:(n-1)]/sum(deg[1:(n-1)]))
                x[idx,n]=1
                x=mgraph.u2d(mgraph.d2u(x),input=input)
            }
        } else if (type == "gnp") {
            if (is.null(p[1])) {
                stop("Error: For graphs of type 'gnp' you must give the edge probabilty 'p'!")
            } 
            if (p < 0 | p > 1) {
                stop("Error: p must be within 0 and 1!")
            }
            x[]=rbinom(length(x),1,prob=p)
            diag(x)=0
            x=mgraph.u2d(mgraph.d2u(x),input=input)
        } else if (type == "angie") {
            nds=rownames(x)
            done=nds[1]
            nds=nds[-1]
            while (length(nds)>0) {
                tar=sample(done,1)
                x[tar,nds[1]]=1
                done=c(done,nds[1])
                nds=nds[-1]
            }
            while (sum(x) < edges) {
                idx=sample(which(x[upper.tri(x)]==0),1)
                x[upper.tri(x)][idx]=1
            }
            x=mgraph.u2d(mgraph.d2u(x),input=input)
        } else if (type == "werner") {
            x=x[1:6,1:6]
            x[c(1,2),3]=1
            x[3,4]=1
            x[4,5:6]=1
            x[5,6]=1
        } else if (type == "orion") {
            nodes <- 20
            A <- matrix(0, nrow = nodes, ncol = nodes)
            rownames(A) <- colnames(A) <- c(
                                            "X2",
                                            "X1", "xi", "mu", "bet",
                                            "mei", "alk", "alm", "min", "sai",
                                            "rig", "pi3", "pi1", "pi2", "pi4",
                                            "pi5", "pi6", "bel", "14", "v"
                                            )
            st <- c(
                    "pi1", "pi2", "pi3", "pi4", "pi5",
                    "bel", "14", "bel", "mei", "bet", "mu", "xi",
                    "v", "xi", "X1", "bel", "min", "alm", "min",
                    "rig", "sai", "alk" )
            ed <- c(
                    "pi2", "pi3", "pi4", "pi5", "pi6",
                    "14", "pi1", "mei", "bet", "mu", "xi", "v",
                    "X1", "X2", "X2", "min", "alm", "alk", "rig",
                    "sai", "alk", "bet")
            for (i in 1:length(st)) {
                A[st[i], ed[i]] <- 1
            }  
            x=A
        } else if (type %in% c("cluster","hubs")) {
            size = nodes %/% k
            rem  = nodes %%  k
            esize= edges %/% k
            ree  = edges %%  k
            pos=0
            for (i in 1:k) {
                s=size
                e=esize
                if (rem>0) {
                    s=size+1; rem=rem-1
                }
                if (ree>0) {
                    e=e+1; ree=ree-1
                }
                if (type == "cluster") {
                    g=mgraph.new(type="angie",nodes=s,edges=e)
                } else {
                    g=matrix(c(0,rep(1,s-1),rep(0,s*s-s)),ncol=s,byrow=TRUE)
                }
                x[(pos+1):(pos+nrow(g)),(pos+1):(pos+nrow(g))]=g 
                pos=pos+s

            }
            x=mgraph.u2d(mgraph.d2u(x),input=input)
        } else if (type == "regular") {
            if (k %in% c(1,3)) {
                if (nodes %% 2 != 0) {
                    stop("regular graphs with k = 1 or k = 3 must have an even number of nodes")
                }
            }
            if (k == 1) {
                for (i in seq(1,nrow(x)-1,by=2)) {
                    x[i,i+1]=1
                }
            } else if (k <= 3) {
                x=mgraph.new(type="circle",nodes=nodes)
                if (k == 3) {
                    for (i in 1:(nrow(x)/2)) {
                        x[i,i+(nrow(x)/2)]=1
                     }
                 }
            } else {
                stop("Error: Only values of k <= 3 are implemented for regular graphs")
            }
            x=mgraph.u2d(mgraph.d2u(x),input=input)
        }
    } else {
        stop("either a matrix or a type must be given")
    }
    if (mode=="undirected") {
        x=mgraph.d2u(x)
    }
    class(x)="mgraph"
    return(x)
    
}

#' 
#' @title create names for nodes and other data structures
#' 
#' @description This function aids in creating standard node labels for graphs.
#' 
#' @param n - how many labels
#' @param prefix one or more prefixes to be used, default: NULL.
#'
#' @examples
#' mgraph.autonames(12)
#' mgraph.autonames(12,LETTERS[1:4])
#' mgraph.autonames(12,"R")
#'
#' @author Masiar Novine, Detlef Groth
#' 
#' @export
#' 

mgraph.autonames <- function (n,prefix=NULL) {
    if (is.null(prefix[1])) {
        if (n<=26) {
            nms=LETTERS[1:n]
        } else if (n <= 26*9) {
            nms=mgraph.autonames(n,prefix=LETTERS)
        } else {
            nms=mgraph.autonames(n,prefix="N")
        }
        return(nms)
    } else {
        nms=prefix
        ln <- ceiling(n / length(nms))
        nms_tmp <- rep(nms, ln)[1:n]
        ptf <- rep(1:ln, each=length(nms))[1:n]
        frmt <- formatC(ptf, flag="0", width=log10(ln) + 1)
        return(paste0(nms_tmp, frmt))
    }
}

#' 
#' @title extract graph components
#' 
#' @description Return graph components, nodes which are connected are within the same component.
#' 
#' @param g a mgraph object or an adjacency matrix or an adjacency list
#'
#' @examples
#' R = mgraph.new(type="random",nodes=20,edges=25)
#' mgraph.components(R)
#' @export
#' 

mgraph.components <- function (g) {
    A=g
    A=as.matrix(A)
    A=A+t(A)
    A[A>0]=1
    comp=c()
    P=asg.shortest.paths(A)
    nodes=rownames(A)
    x=1
    while (length(nodes) > 0) {
        n=nodes[1]
        idx=which(P[n,] < Inf)
        ncomp=rep(x,length(idx))
        names(ncomp)=rownames(P)[idx]
        comp=c(comp,ncomp)
        nodes=setdiff(nodes,rownames(P)[idx])
        x=x+1
    }
    return(comp[rownames(A)])
}

#' 
#' @title number of undirected or incoming and outgoing edges.
#' 
#' @description This function returns the degree centrality measure for every node.
#' 
#' @param g a mgraph object or an adjacency matrix
#' @param mode either 'undirected', 'out' or 'in', default: 'undirected'
#'
#' @examples
#' par(mfrow=c(1,2),mai=rep(0.2,4))
#' A=mgraph.new(type="regular",nodes=8,k=3)
#' plot(A,layout="circle"); 
#' plot(mgraph.d2u(A),layout="circle"); 
#' mgraph.degree(A)
#' mgraph.degree(A,mode="out")
#' mgraph.degree(A,mode="in")
#'
#' @export
#' 
mgraph.degree <- function (g,mode="undirected") {
    if (mode == "undirected") {
        g=mgraph.d2u(g)
    } else if (mode == "in") {
        g=t(g)
    } 
    g[abs(g)!=0]=1
    d=apply(g,1,sum)
    names(d)=rownames(g)
    return(d)
}


#' 
#' @title create undirected graph out of a directed graph
#' 
#' @description This function gets an directed graph and convertes all edges from directed ones to undirected ones.
#'   The number of edges should stay the same, the edge sign (+ or -) stays the same.
#' 
#' @param g a mgraph object or an adjacency matrix
#'
#' @examples
#' par(mfrow=c(1,2),mai=rep(0.2,4))
#' A=mgraph.new(type="angie",nodes=4,edges=4)
#' A
#' U=mgraph.d2u(A)
#' U
#' plot(A); plot(U)
#'
#' @export
#' 

mgraph.d2u <- function (g) {
    g[lower.tri(g)]=g[lower.tri(g)]+t(g)[lower.tri(g)]
    g[upper.tri(g)]=g[upper.tri(g)]+t(g)[upper.tri(g)]    
    g[g>0]=1
    g[g<0]=-1
    return(g)
}

#' 
#' @title create correlated data for the given graph
#' 
#' @description This function is a short implementation of the algorithm in Novine et. al. 2022.
#' 
#' @param g a mgraph object or an adjacency matrix
#' @param n the number of measurements per node, default: 100
#' @param iter the number of iterations, default: 15
#' @param sd initial standard deviation, default: 2
#' @param val initial node value, default: 100
#' @param prop proportion of the target node value take from the source node, default: 0.05
#' @param noise the sd for the noise value added after each iteration using rnorm function with mean 0, default: 1
#' @param method the method for data generation, either 'mc' for using Monte Carlo simulation or 'pc' for using a precision matrix, default: 'mc'
#'
#' @examples
#' par(mfrow=c(1,2),mai=rep(0.2,4))
#' A=mgraph.new(type="angie",nodes=8,edges=10)
#' plot(A,layout="circle"); 
#' C=mgraph.graph2data(A,prop=0.05)
#' round(cor(t(C)),2)
#' # Here an example which shows that with increasing number of
#' # iterations the correlations between the nodes increase.
#' par(mfrow=c(2,2),mai=rep(0.1,4))
#' W=mgraph.new(type="werner")
#' plot(W,layout='werner')
#' for (i in c(15,30,50)) {
#'      data=mgraph.graph2data(W,n=200,iter=i)
#'      as=asg.new(t(data),method="spearman",alpha=0.1)
#'      plot(mgraph.new(as$theta),layout='werner',edge.text=round(as$sigma,2))
#'      text(2.5,1.5,paste("iter =",i),cex=2)
#'   }
#'
#' @export
#' 

mgraph.graph2data <- function (g,n=100,iter=15,val=100,sd=2,prop=0.05,noise=1,method="mc") {
    A=g
    res=matrix(0,ncol=n,nrow=nrow(A))
    rownames(res)=rownames(A)
    stopifnot(method %in% c('mc','pm'))
    if (method == "pm") {
        data=mgraph.pmatrix(g,mu=val,n=n)
        return(data)
    }
    for (i in 1:n) {
        units=rnorm(nrow(A),mean=val,sd=sd)
        names(units)=rownames(A)
        for (j in 1:iter) {
            for (node in sample(rownames(A))) {
                targets=colnames(A)[which(A[node,]!=0)]
                for (target in sample(targets)) {
                    P=abs(A[node,target])
                    nval=units[[node]]*(prop*P)
                    nval=nval+units[[target]]*(1-(prop*P))
                    if (A[node,target]<0) {
                        diff=nval-units[[target]]
                        nval=units[[target]]-diff
                    }
                    units[[target]]=nval;
                }
            }
            units=units+rnorm(length(units),sd=noise)
        }
        res[,i]=units
    }
    return(res)
}

# x = adjacency matrix, factor strength
mgraph.pmatrix <- function (x,factor=1,mu=100,n=100) {
    adj2cov = function (x,factor=1) {
        x[x!=0]=x[x!=0]+factor
        diag(x)=apply(x,1,sum)+factor
        return(x)
    }
    cov2data = function (x,mu=rep(0,nrow(x)),n=100) {
        data=MASS::mvrnorm(n,mu=mu,Sigma=x)
        colnames(data)=colnames(x)
        return(data)
    }
    
    pcor2cor = function (x, tol = sqrt(.Machine$double.eps)) {
        x = -x
        rn=rownames(x)
        diag(x) = -diag(x)
        x = MASS::ginv(x, tol = tol)
        rownames(x)=colnames(x)=rn
        return(cov2cor(x))
    }
    y=mgraph.d2u(x)
    COV=adj2cov(y,factor=factor)
    COR=pcor2cor(COV)
    data=cov2data(COR,mu=rep(mu,nrow(x)),n=n)
    return(t(data))
}

#' 
#' @title return node colors for directed graphs.
#' 
#' @description This function simplifies automatic color coding of nodes for directed graphs.
#'   Nodes will be colored based on their degree properties, based
#'   on their incoming and outcoming edges.
#' 
#' @param g a mgraph object or an adjacency matrix or an adjacency list
#' @param col default colors for nodes with only incoming, in- and outgoing and only outgoing edges, default: c("skyblue","grey80","salmon")
#'
#' @examples
#' 
#' par(mfrow=c(1,2),mai=rep(0.1,4))
#' A=mgraph.new(type="random",nodes=6,edges=8)
#' cols=mgraph.nodeColors(A)
#' mgraph.degree(A,mode="in")
#' mgraph.degree(A,mode="out")
#' cols
#' plot(A, layout="star")
#' plot(A, layout="star",vertex.color=cols) 
#'
#' @export
#' 

mgraph.nodeColors <- function (g,col=c("skyblue","grey80","salmon")) {
    colors = rep(col[2],nrow(g))
    out    = mgraph.degree(g,mode="out")
    inc     = mgraph.degree(g,mode="in")    
    colors[out >  0 & inc == 0] = col[3]
    colors[out == 0 & inc >  0] = col[1]    
    return(colors)
}

#' 
#' @title plot a given graph or adjacency matrix
#' 
#' @title This function is a plotting function for mgraph objects. All arguments are just forwarded to the asg.mplot function.
#' 
#' @param x a mgraph object or an adjacency matrix or an adjacency list
#' @param layout the layout, either a matrix or string in addition to the layout parameters for plot.asg the layout strings 'werner' for 6 node graphs and 'orion' for 20 node graphs are supported, default: 'sam'
#' @param \ldots all remaining arguments are forwarded to the asg.mplot function
#'
#' @examples
#' par(mfrow=c(2,2),mai=rep(0.2,4))
#' G=mgraph.new(type="angie")
#' plot(G, layout="sam")
#' plot(G, layout="circle") 
#' plot(G, layout="star",vertex.color="grey90") 
#' M=matrix(0,ncol=5,nrow=5)
#' diag(M)=0
#' M[upper.tri(M)]= as.integer(rlnorm(10,0.35))
#' M[lower.tri(M)]=t(M)[lower.tri(M)]
#' rownames(M)=colnames(M)=LETTERS[1:5]
#' M=mgraph.new(M)
#' M
#' identical(M,t(M))
#'
#' @export
#' 
#' @author Detlef Groth, Cedric Moris
#' 
#' @seealso \link[asg:plot.asg]{plot.asg(x)}
#' 

plot.mgraph = function (x, layout='sam',...) {
    
    if (class(layout)[1] == "character" && layout == "werner") {
        layout=matrix(c(1,1,1,3,2,2,3,2,4,3,4,1),ncol=2,byrow=TRUE)
        colnames(layout)=c("x","y")
        rownames(layout)=rownames(x)
    } else if (class(layout)[1] == "character" && layout == "orion") {
        layout <- matrix(c(
                        -0.91, 1, # X2
                        -0.79, 0.99, # X1
                        -0.96, 0.79, # xi
                        -0.8, 0.65, # mu
                        -0.75, 0.57, # alpha
                        -0.48, 0.65, # lambda
                        -0.56, 0.24, # zeta
                        -0.47, 0.28, # epsilon
                        -0.40, 0.32, # delta (0.43-0.40)
                        -0.7, 0, # kappa
                        -0.2, 0.04, # beta
                        0.19, 0.53, # pi3
                        0.1, 0.65, # pi1
                        0.17, 0.61, # pi2
                        0.18, 0.44, # pi4
                        0.15, 0.32, # pi5
                        0.09, 0.27, # pi6
                        -0.38, 0.52, # gamma
                        -0.14, 0.59, # 14
                        -0.87, 0.82 # nu v # (-0.9,0.82)
                        ),nrow = 20, byrow = TRUE)
               colnames(layout)=c("x","y")
            rownames(layout)=rownames(x)
       } 
        plot.asg(as.matrix(x),layout=layout,...)
}

#' 
#' @title create a directed graph out of an undirected graph
#' 
#' @description This function creates a directed graph from an undirected one by the given input nodes. Input nodes can be chosen by names or a number for random selection of input nodes will be given.
#' Input nodes will have at least shortest path distance to other input nodes of pathlength two.
#' Selected input nodes will draw in each iteration outgoing edges to other nodes in the nth iteration neighborhood. The input
#' nodes will alternatively select the next edges on the path to not visited nodes. All edges will be only visited onces.
#' 
#' @param g a mgraph object created with _mgraph$new_.
#' @param input number or names of input nodes in the graph, if number of input nodes is smaller than number of components, for each component one input node is automatically created, default: 2
#' @param negative proportion of inhibitive associations in the network value between 0 and 1 are acceptable, default 0.0
#' @param shuffle should just the edge directions beeing shuffled, if TRUE the graph will be very random without a real structure or chains of associations, default: FALSE
#'  
#' @return a mgraph object
#' 
#' @examples
#' 
#' par(mfrow=c(2,2),mai=rep(0.1,4))
#' G=mgraph.new(type="angie",nodes=7,edges=9)
#' mgraph.degree(G,mode='in')
#' U=mgraph.d2u(G)
#' H=mgraph.u2d(U,input=c("G","E"))
#' identical(G,H)
#' I=mgraph.u2d(U,shuffle=TRUE)
#' identical(G,I)
#' lay=asg.layout(G)
#' plot(G,layout=lay,vertex.color=mgraph.nodeColors(G))
#' plot(U,layout=lay)
#' plot(H,layout=lay,vertex.color=mgraph.nodeColors(H))
#' plot(I,layout=lay,vertex.color=mgraph.nodeColors(I))
#'
#' @author Detlef Groth, Masiar Novine
#' 
#' @export
#' 
mgraph.u2d <- function (g,input=2,negative=0.0,shuffle=FALSE) {
    if (shuffle) {
        h=g
        idx=sample(rownames(h))
        h=h[idx,idx]
        h[lower.tri(h)]=0
        h=h[rownames(g),rownames(g)]
        class(h)="mgraph"
        return(h)          
    } else {
        A=g
        # creates from undirected a directed one
        # A must be an symmetric adjacency matrix
        # MN The new check is 5x faster and takes less memory
        #if (!identical(A[lower.tri(A)], t(A)[lower.tri(A)])) {
        if (!all(A == t(A))) {
            stop("adjacency matrix must be symmetric")
        }
        if (negative < 0 || negative > 1) {
            stop("negative proportions must be within 0 and 1")
        }
        # undirected matrix
        U=A
        # future directed matrix
        D=U
        D[]=0
        neighbours=c()
        if (class(input)=='numeric') {
            nodes=c()
            
            comps=mgraph.components(A)
            if (max(comps)>1) {
                for (i in 1:max(comps)) {
                    if (length(which(comps==i)) > 1) {
                        node=sample(names(which(comps==i)),1)
                        neighbours=c(neighbours,rownames(U)[which(U[node,]==1)],node)
                        nodes=c(nodes,node)
                    }
                }
            }
            n=input-length(nodes)
            while (n>0) {
                rnames=setdiff(rownames(U),c(neighbours))
                node=sample(rnames,1)
                n=n-1
                neighbours=c(neighbours,rownames(U)[which(U[node,]==1)],node)
                nodes=c(nodes,node)
            }
        } else {
            nodes=input
            n=0
        }
        visits=list()
        while (length(nodes)>0) {
            node=nodes[1]
            edges=which(U[node,]==1)
            newnodes=colnames(U)[edges]
            if (length(nodes)==1) {
                nodes=newnodes
            } else {
                nodes=c(nodes[2:length(nodes)],newnodes)
            }
            D[node,edges]=1
            U[node,]=0
            U[,node]=0
        }
        A[]=D
        if (negative>0) {
            idx=which(A==1)
            n=floor(length(idx)*negative)
            if(n>0) {
                min=sample(idx,n)
                A[min]=-1
            }
        }
        class(A)="mgraph"
        return(A)
    }
}

