#ifndef LINKED_LIST_RIP_TOPOLOGY_H
#define LINKED_LIST_RIP_TOPOLOGY_H

#include <string>
#include <map>
#include <set>
#include <vector>

// 链表节点结构
struct RipNode {
    std::string source;     // 源节点
    std::string destination;// 目的网络
    std::string nextHop;    // 下一跳
    int hops;               // 跳数
    RipNode* next;          // 下一个节点指针

    RipNode(const std::string& src, const std::string& dest, const std::string& next, int h)
        : source(src), destination(dest), nextHop(next), hops(h), next(NULL) {}
};

// 基于链表的RIP拓扑还原器
class LinkedListRipTopology {
public:
    LinkedListRipTopology() : head_(NULL) {}
    ~LinkedListRipTopology();

    // 添加路由条目到链表
    void addRoute(const std::string& src, const std::string& dest, const std::string& next, int hops);

    // 构建拓扑图
    void buildTopology();

    // 获取完整拓扑 (节点 -> 直接连接的节点集合)
    const std::map<std::string, std::set<std::string>>& getTopology() const;

    // 获取所有直接物理连接
    const std::vector<std::pair<std::string, std::string>>& getPhysicalLinks() const;

    // 打印拓扑图
    void printTopology() const;

private:
    RipNode* head_;

    // 构建的拓扑图
    std::map<std::string, std::set<std::string>> topology_;

    // 物理连接列表
    std::vector<std::pair<std::string, std::string>> physicalLinks_;

    // 已处理的连接对(避免重复)
    std::set<std::pair<std::string, std::string>> processedLinks_;

    // 提取物理连接
    void extractPhysicalConnections();

    // 禁止拷贝和赋值
    LinkedListRipTopology(const LinkedListRipTopology&);
    LinkedListRipTopology& operator=(const LinkedListRipTopology&);
};

#endif // LINKED_LIST_RIP_TOPOLOGY_H