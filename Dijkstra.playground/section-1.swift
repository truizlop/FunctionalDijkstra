/*
Dijkstra's shortest path algorithm in functional programming
*/

protocol Graph{
    func distance(from : Int, to : Int) -> Double?
    func nodes() -> [Int]
    func adjacentNodes(to : Int) -> [Int]
}

extension Array{
    func head() -> Element? {
        return self.first
    }
    
    func tail() -> [Element] {
        return Array(self.dropFirst())
    }
}

// ---------------------------- Test data -------------------------------------

class Map : Graph{
    func distance(from : Int, to : Int) -> Double?{
        switch from{
            case 0:
                return [0,         7,     9, .None, .None,    14][to];
            case 1:
                return [7,         0,    10,    15, .None, .None][to];
            case 2:
                return [9,        10,     0,    11, .None,     2][to];
            case 3:
                return [.None,    15,    11,     0,     6, .None][to];
            case 4:
                return [.None, .None, .None,     6,     0,     9][to];
            case 5:
                return [14,    .None,     2, .None,     9,     0][to];
            default:
                return .None;
        }
    }
    
    func nodes() -> [Int]{
        return [0, 1, 2, 3, 4, 5];
    }
    
    func adjacentNodes(to : Int) -> [Int]{
        switch to{
            case 0:
                return [1,2,5];
            case 1:
                return [0,2,3];
            case 2:
                return [0,1,3,5];
            case 3:
                return [1,2,4];
            case 4:
                return [3,5];
            case 5:
                return [0,2,4];
            default:
                return [];
        }
    }
}

// --------------------------- Functional Dijkstra's Algorithm -----------------------------------

func shortestPath(graph : Graph, from : Int, to : Int) -> (Double?, String){
    
    let distances = graph.nodes().map({ graph.distance(from, to: $0) })
    let previous : [Int?] = graph.nodes().map({
        switch graph.distance(from, to: $0){
            case .Some(_):
                return from
            case .None:
                return .None
        }
    })
    let visited = [Bool](count: graph.nodes().count, repeatedValue: false)
    let queue = graph.nodes().filter({graph.distance(from, to: $0) != nil}).map({ ($0, graph.distance(from, to: $0)!) }).sort({ $0.1 < $1.1 });

    return shortestPath(graph, from: from, to: to, distances: distances, previous: previous, visited: visited, queue: queue)
}

func shortestPath(graph : Graph, from : Int, to : Int, distances : [Double?], previous : [Int?], visited : [Bool], queue : [(Int, Double)]) -> (Double?, String){
    
    switch queue.head(){
        case .None:
            return (distances[to], extractPath(previous, from: from, to: to))
        case .Some(let (currentNode, _)):
            switch visited[currentNode]{
                case true:
                    return shortestPath(graph, from: from, to: to, distances: distances, previous: previous, visited: visited, queue: queue.tail())
                case false:
                    let newVisited = graph.nodes().map({ $0 == currentNode ? true : visited[$0]})
                    let newValues : [(Double?, Int?, (Int, Double)?)] = graph.nodes().map({
                        updateDistance(graph, currentNode: currentNode, distances: distances, previous: previous, visited: visited, node: $0)
                    })

                    let newDistances = newValues.map({ $0.0 })
                    let newPrevious = newValues.map({ $0.1 })
                    let newQueue : [(Int, Double)] = newValues.map({ $0.2 }).filter({ $0 != nil }).map({ $0! })
                    let completeQueue = (newQueue + queue.tail()).sort({ $0.1 < $1.1 });
                    
                    return shortestPath(graph, from: from, to: to, distances: newDistances, previous: newPrevious, visited: newVisited, queue: completeQueue)
            }
    }
}

func updateDistance(graph : Graph, currentNode : Int, distances : [Double?], previous : [Int?], visited : [Bool], node : Int) -> (Double?, Int?, (Int, Double)?){
    switch (graph.adjacentNodes(currentNode).contains(node), visited[node]){
        case (_, true), (false, _):
            return (distances[node], previous[node], .None)
        default:
            switch (distances[currentNode], distances[node]){
                case let (.Some(distanceToCurrentNode), .Some(distanceToNode)):
                    let newDistance = distanceToCurrentNode + graph.distance(currentNode, to: node)!
                    return distanceToNode > newDistance ? (newDistance, currentNode, (currentNode, newDistance)) : (distances[node], previous[node], .None)
                case let (.Some(distanceToCurrentNode), .None):
                    let newDistance = distanceToCurrentNode + graph.distance(currentNode, to: node)!
                    return (newDistance, currentNode, (currentNode, newDistance))
                default:
                    return (distances[node], previous[node], .None)
            }
    }
}

// --------------------------- Extract path -------------------------------------

func extractPath(previous : [Int?], from : Int, to : Int) -> String {
    return extractPath(previous, from: from, to: to, path: "");
}

func extractPath(previous : [Int?], from : Int, to : Int, path : String) -> String {
    switch to {
        case from:
            return "\(from)" + path;
        default:
            return extractPath(previous, from: from, to: previous[to]!, path: " -> \(to)" + path);
    }
}

// ------------------------------------------------------------------------------

let map = Map()
print(shortestPath(map, from: 0, to: 4))



