#ifndef LINKED_LIST_RIP_TOPOLOGY_H
#define LINKED_LIST_RIP_TOPOLOGY_H

#include <string>
#include <map>
#include <set>
#include <vector>

// ����ڵ�ṹ
struct RipNode {
    std::string source;     // Դ�ڵ�
    std::string destination;// Ŀ������
    std::string nextHop;    // ��һ��
    int hops;               // ����
    RipNode* next;          // ��һ���ڵ�ָ��

    RipNode(const std::string& src, const std::string& dest, const std::string& next, int h)
        : source(src), destination(dest), nextHop(next), hops(h), next(NULL) {}
};

// ���������RIP���˻�ԭ��
class LinkedListRipTopology {
public:
    LinkedListRipTopology() : head_(NULL) {}
    ~LinkedListRipTopology();

    // ���·����Ŀ������
    void addRoute(const std::string& src, const std::string& dest, const std::string& next, int hops);

    // ��������ͼ
    void buildTopology();

    // ��ȡ�������� (�ڵ� -> ֱ�����ӵĽڵ㼯��)
    const std::map<std::string, std::set<std::string>>& getTopology() const;

    // ��ȡ����ֱ����������
    const std::vector<std::pair<std::string, std::string>>& getPhysicalLinks() const;

    // ��ӡ����ͼ
    void printTopology() const;

private:
    RipNode* head_;

    // ����������ͼ
    std::map<std::string, std::set<std::string>> topology_;

    // ���������б�
    std::vector<std::pair<std::string, std::string>> physicalLinks_;

    // �Ѵ�������Ӷ�(�����ظ�)
    std::set<std::pair<std::string, std::string>> processedLinks_;

    // ��ȡ��������
    void extractPhysicalConnections();

    // ��ֹ�����͸�ֵ
    LinkedListRipTopology(const LinkedListRipTopology&);
    LinkedListRipTopology& operator=(const LinkedListRipTopology&);
};

#endif // LINKED_LIST_RIP_TOPOLOGY_H