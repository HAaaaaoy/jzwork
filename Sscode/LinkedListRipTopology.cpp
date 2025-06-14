#include "LinkedListRipTopology.h"
#include <iostream>
#include <algorithm>

LinkedListRipTopology::~LinkedListRipTopology() {
    RipNode* current = head_;
    while (current != NULL) {
        RipNode* next = current->next;
        delete current;
        current = next;
    }
}

void LinkedListRipTopology::addRoute(const std::string& src, const std::string& dest, const std::string& next, int hops) {
    RipNode* newNode = new RipNode(src, dest, next, hops);

    if (head_ == NULL) {
        head_ = newNode;
    }
    else {
        RipNode* current = head_;
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = newNode;
    }
}

void LinkedListRipTopology::buildTopology() {
    topology_.clear();
    physicalLinks_.clear();
    processedLinks_.clear();

    // 1. ������ȡ����ֱ����������
    extractPhysicalConnections();

    // 2. ������������ͼ
    RipNode* current = head_;
    while (current != NULL) {
        // ���Դ�ڵ㵽��һ��������
        if (current->hops == 1) {
            topology_[current->source].insert(current->nextHop);
        }

        // ���Դ�ڵ㵽Ŀ�����������(�������>1)
        if (current->hops > 1) {
            topology_[current->source].insert(current->destination);
        }

        current = current->next;
    }
}

const std::map<std::string, std::set<std::string>>& LinkedListRipTopology::getTopology() const {
    return topology_;
}

const std::vector<std::pair<std::string, std::string>>& LinkedListRipTopology::getPhysicalLinks() const {
    return physicalLinks_;
}

void LinkedListRipTopology::printTopology() const {
    std::cout << "Network Topology from RIP Table (Linked List):" << std::endl;
    std::cout << "=============================================" << std::endl;

    // ��ӡ��������
    std::cout << "\nPhysical Links:" << std::endl;
    for (std::vector<std::pair<std::string, std::string> >::const_iterator it = physicalLinks_.begin();
        it != physicalLinks_.end(); ++it) {
        std::cout << it->first << " --- " << it->second << std::endl;
    }

    // ��ӡ��������
    std::cout << "\nFull Topology View:" << std::endl;
    for (std::map<std::string, std::set<std::string> >::const_iterator nodeIt = topology_.begin();
        nodeIt != topology_.end(); ++nodeIt) {
        std::cout << nodeIt->first << " -> ";

        for (std::set<std::string>::const_iterator destIt = nodeIt->second.begin();
            destIt != nodeIt->second.end(); ++destIt) {
            std::cout << *destIt << " ";
        }

        std::cout << std::endl;
    }
}

void LinkedListRipTopology::extractPhysicalConnections() {
    RipNode* current = head_;
    while (current != NULL) {
        if (current->hops == 1) {
            // �����淶�������Ӷ�(����ĸ˳��)
            std::pair<std::string, std::string> link;
            if (current->source < current->nextHop) {
                link = std::make_pair(current->source, current->nextHop);
            }
            else {
                link = std::make_pair(current->nextHop, current->source);
            }

            // ���δ����������
            if (processedLinks_.find(link) == processedLinks_.end()) {
                physicalLinks_.push_back(std::make_pair(current->source, current->nextHop));
                processedLinks_.insert(link);
            }
        }
        current = current->next;
    }
}